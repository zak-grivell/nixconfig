import json
import os
import traceback
from dataclasses import dataclass
from socket import AF_UNIX, SOCK_STREAM, socket


@dataclass
class Window:
    id: str
    focused: bool


@dataclass
class Workspace:
    id: str
    windows: list[Window]
    focused: bool


SOCKET_PATH = "/tmp/aeroserver.sock"
USERNAME = "zakgrivell"
AEROSPACE_SOCKET = f"/tmp/bobko.aerospace-{USERNAME}.sock"


def next_valid_spot(nums: set, start: int):
    candidate = start

    while candidate not in nums or candidate < len(nums) + 1:
        candidate += 1

    return candidate


def new_valid_space(nums: set):
    candidate = 1

    while True:
        while candidate in nums:
            candidate += 1
        yield candidate
        candidate += 1


def aerospace_send_command(client_sock: socket, args: list[str]):
    """Helper to send command and return stdout string."""
    print(f"----------- [{args}] ---------- \n\n")
    payload = {"command": "", "args": args, "stdin": ""}

    client_sock.sendall((json.dumps(payload) + "\n").encode("utf-8"))

    # Receive response
    response_data = b""
    # while not response_data.endswith(b"\n"):
    chunk = client_sock.recv(4096)
    # print("CHUNK:", repr(chunk))
    # if not chunk:
    #     break
    response_data += chunk

    print(response_data)

    response_json = json.loads(response_data.decode("utf-8"))

    print("res: ", response_json)
    if response_json["stdout"]:
        data_json = json.loads(response_json["stdout"])
        print("data: ", data_json)

        print("\n" * 5)

        return data_json

    return None


def list_windows(
    client_sock: socket,
) -> tuple[dict[str, Workspace], str | None, str | None]:
    """
    Runs list-windows with the specific format:
    %{workspace} %{window-id} %{workspace-is-focused}
    """

    workspaces = aerospace_send_command(
        client_sock,
        ["list-windows", "--all", "--json", "--format", "%{workspace} %{window-id}"],
    )

    res = aerospace_send_command(
        client_sock,
        [
            "list-windows",
            "--focused",
            "--json",
            "--format",
            "%{workspace} %{window-id}",
        ],
    )

    focused_window = res[0]["window-id"] if len(res) > 0 else None
    focused_workspace = res[0]["workspace"] if len(res) > 0 else None

    output: dict[str, Workspace] = {}

    for entry in workspaces:
        wid = entry["window-id"]
        workspace = entry["workspace"]

        output.setdefault(
            workspace, Workspace(workspace, [], workspace == focused_workspace)
        )
        output[workspace].windows.append(Window(wid, wid == focused_window))

    return output, focused_window, focused_workspace


def move_node_to_workspace(
    client_sock: socket, workspace_name: str, window_id: str, focused: bool
):
    """
    Moves a specific window node to a target workspace.
    """

    print(f"moving wid({window_id}) to workspace({workspace_name})")

    aerospace_send_command(
        client_sock,
        [
            "move-node-to-workspace",
            str(workspace_name),
            "--window-id",
            str(window_id),
        ]
        + (["--focus-follows-window"] if focused else []),
    )


def reset_window(client_sock: socket):
    data, focused_window, focused_workspace = list_windows(client_sock)

    workspaces = data.keys()

    valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

    gen = new_valid_space(valid)

    if focused_window:
        move_node_to_workspace(client_sock, str(next(gen)), focused_window, True)


def process(client_sock: socket):
    data, focused_window, focused_workspace = list_windows(client_sock)

    workspaces = data.keys()

    valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

    gen = new_valid_space(valid)

    while (n := next(gen)) != len(valid) + 1:
        spot = next_valid_spot(valid, n)

        for window in data[str(spot)].windows:
            move_node_to_workspace(client_sock, n, window.id, window.focused)

        valid.remove(spot)
        valid.add(n)


def yank(client_sock: socket):
    data, focused_window, focused_workspace = list_windows(client_sock)
    with open("/tmp/aerospace_window", "w") as f:
        if focused_window:
            f.write(str(focused_window))


def paste(client_sock: socket):
    with open("/tmp/aerospace_window") as f:
        data, focused_window, focused_workspace = list_windows(client_sock)

        if focused_workspace:
            move_node_to_workspace(
                client_sock, str(focused_workspace), f.readline(), False
            )


if os.path.exists(SOCKET_PATH):
    os.unlink(SOCKET_PATH)

with socket(AF_UNIX, SOCK_STREAM) as client_sock:
    client_sock.connect(AEROSPACE_SOCKET)

    print(list_windows(client_sock))

    with socket(AF_UNIX, SOCK_STREAM) as server_sock:
        try:
            server_sock.bind(SOCKET_PATH)
            os.chmod(SOCKET_PATH, 0o666)
            server_sock.listen(1)

            print("Aerospace UNIX server started at", SOCKET_PATH)
        except Exception as e:
            print("error starting socket", e)

        while True:
            conn, _ = server_sock.accept()

            print("conn accepted")

            data = conn.recv(1024).decode("utf-8").strip()

            try:
                match data:
                    case "process":
                        process(client_sock)
                        conn.sendall(b"OK")
                    case "new-window":
                        reset_window(client_sock)
                        conn.sendall(b"OK")
                    case "yank":
                        yank(client_sock)
                        conn.sendall(b"OK")
                    case "paste":
                        paste(client_sock)
                        conn.sendall(b"OK")
                    case "running":
                        conn.sendall(b"server go brr")
                    case _:
                        conn.sendall(b"ERR unknown command")
            except Exception as e:
                error_msg = f"ERR {e}\n{traceback.format_exc()}"
                print(error_msg)
                conn.sendall(error_msg.encode())

            conn.close()
