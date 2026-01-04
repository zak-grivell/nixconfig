import json
import os
import traceback
from dataclasses import dataclass
from socket import AF_UNIX, SOCK_STREAM, socket

ban_list = {"SecurityAgent", "coreautha"}


@dataclass
class Window:
    id: str
    focused: bool
    name: str


@dataclass
class Workspace:
    id: str
    windows: dict[str, Window]
    focused: bool


SOCKET_PATH = "/tmp/aeroserver.sock"
USERNAME = "zakgrivell"
AEROSPACE_SOCKET = f"/tmp/bobko.aerospace-{USERNAME}.sock"


class AerospaceSocket:
    def __init__(self):
        self._sock = None

    def _is_alive(self):
        if self._sock is None:
            return False
        try:
            self._sock.send(b"")
            return True
        except OSError:
            return False

    def _connect(self):
        s = socket(AF_UNIX, SOCK_STREAM)
        s.connect(AEROSPACE_SOCKET)

        self._sock = s

    def _close(self):
        if self._sock is not None:
            try:
                self._sock.close()
            finally:
                self._sock = None

    def get(self):
        if not self._is_alive():
            self._close()
            self._connect()
        return self._sock

    def send(self, args: list[str]):
        """Helper to send command and return stdout string."""
        print(f"----------- [{args}] ---------- \n\n")
        payload = {"command": "", "args": args, "stdin": ""}

        sock = self.get()

        sock.sendall((json.dumps(payload) + "\n").encode("utf-8"))

        # Receive response
        response_data = b""
        # while not response_data.endswith(b"\n"):
        chunk = sock.recv(4096)
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


def list_windows(
    aerospace_socket: AerospaceSocket,
) -> tuple[dict[str, Workspace], str | None, str | None]:
    """
    Runs list-windows with the specific format:
    %{workspace} %{window-id} %{workspace-is-focused}
    """

    workspaces = aerospace_socket.send(
        [
            "list-windows",
            "--all",
            "--json",
            "--format",
            "%{workspace} %{window-id} %{app-name}",
        ],
    )

    res = aerospace_socket.send(
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
        name = entry["app-name"]

        output.setdefault(
            workspace, Workspace(workspace, {}, workspace == focused_workspace)
        )
        output[workspace].windows[wid] = Window(wid, wid == focused_window, name)

    return output, focused_window, focused_workspace


def move_node_to_workspace(
    aerospace_socket: AerospaceSocket,
    workspace_name: str,
    window_id: str,
    focused: bool,
):
    """
    Moves a specific window node to a target workspace.
    """

    print(f"moving wid({window_id}) to workspace({workspace_name})")

    aerospace_socket.send(
        [
            "move-node-to-workspace",
            str(workspace_name),
            "--window-id",
            str(window_id),
        ]
        + (["--focus-follows-window"] if focused else []),
    )


def reset_window(aerospace_socket: AerospaceSocket):
    data, focused_window, focused_workspace = list_windows(aerospace_socket)

    workspaces = data.keys()

    valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

    gen = new_valid_space(valid)

    if (
        focused_window
        and focused_workspace
        and data[focused_workspace].windows[focused_window].name not in ban_list
    ):
        print(data[focused_workspace].windows[focused_window].name)
        move_node_to_workspace(aerospace_socket, str(next(gen)), focused_window, True)


def process(aerospace_socket: AerospaceSocket):
    data, focused_window, focused_workspace = list_windows(aerospace_socket)

    workspaces = data.keys()

    valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

    gen = new_valid_space(valid)

    while (n := next(gen)) != len(valid) + 1:
        spot = next_valid_spot(valid, n)

        for window in data[str(spot)].windows.values():
            move_node_to_workspace(aerospace_socket, n, window.id, window.focused)

        valid.remove(spot)
        valid.add(n)


def yank(aerospace_socket: AerospaceSocket):
    data, focused_window, focused_workspace = list_windows(aerospace_socket)
    with open("/tmp/aerospace_window", "w") as f:
        if focused_window:
            f.write(str(focused_window))


def paste(aerospace_socket: AerospaceSocket):
    with open("/tmp/aerospace_window") as f:
        data, focused_window, focused_workspace = list_windows(aerospace_socket)

        if focused_workspace:
            move_node_to_workspace(
                aerospace_socket, str(focused_workspace), f.readline(), False
            )


if os.path.exists(SOCKET_PATH):
    os.unlink(SOCKET_PATH)

with socket(AF_UNIX, SOCK_STREAM) as server_sock:
    try:
        server_sock.bind(SOCKET_PATH)
        os.chmod(SOCKET_PATH, 0o666)
        server_sock.listen(1)

        print("Aerospace UNIX server started at", SOCKET_PATH)
    except Exception as e:
        print("error starting socket", e)

    aerospace_socket = AerospaceSocket()

    while True:
        conn, _ = server_sock.accept()

        print("conn accepted")

        data = conn.recv(1024).decode("utf-8").strip()

        try:
            match data:
                case "process":
                    process(aerospace_socket)
                    conn.sendall(b"OK")
                case "new-window":
                    reset_window(aerospace_socket)
                    conn.sendall(b"OK")
                case "yank":
                    yank(aerospace_socket)
                    conn.sendall(b"OK")
                case "paste":
                    paste(aerospace_socket)
                    conn.sendall(b"OK")
                case "running":
                    conn.sendall(b"server go brr")
                case _:
                    conn.sendall(b"ERR unknown command")
        except BrokenPipeError:
            raise
        except Exception as e:
            error_msg = f"ERR {e}\n{traceback.format_exc()}"
            print(error_msg)
            conn.sendall(error_msg.encode())

        conn.close()
