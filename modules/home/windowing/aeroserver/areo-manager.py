import json
import os
import traceback
from dataclasses import dataclass
from json.decoder import JSONDecodeError
from socket import AF_UNIX, SOCK_STREAM, socket

ban_list = {"SecurityAgent", "coreautha"}


@dataclass
class Window:
    id: str
    focused: bool
    name: str


@dataclass
class Workspace:
    number: int
    windows: dict[str, Window]
    focused: bool


@dataclass
class AeroSpaceState:
    workspaces: dict[int, Workspace]
    focused_workspace: int | None
    focused_window: str | None
    mode: str


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

        response_data = b""
        chunk = sock.recv(4096)
        response_data += chunk

        print(response_data)

        response_json = json.loads(response_data.decode("utf-8"))

        print("res: ", response_json)
        if response_json["stdout"]:
            try:
                data_json = json.loads(response_json["stdout"])
            except JSONDecodeError:
                return response_json["stdout"]

            print("data: ", data_json)

            print("\n" * 5)

            return data_json

        return None


def next_valid_spot(nums: set, start: int):
    candidate = start

    while candidate not in nums or candidate < len(nums) + 1:
        candidate += 1

    return candidate


def new_valid_space(nums: dict[int, Workspace]):
    candidate = 1

    while True:
        while candidate in nums:
            candidate += 1
        yield candidate
        candidate += 1


def query_state(aerospace_socket: AerospaceSocket) -> AeroSpaceState:
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
    focused_workspace = int(res[0]["workspace"]) if len(res) > 0 else None

    output: dict[int, Workspace] = {}

    for entry in workspaces:
        wid = entry["window-id"]
        workspace = entry["workspace"]
        name = entry["app-name"]

        output.setdefault(
            int(workspace), Workspace(workspace, {}, workspace == focused_workspace)
        )
        output[int(workspace)].windows[wid] = Window(wid, wid == focused_window, name)

    mode = aerospace_socket.send(["list-modes", "--current"])

    return AeroSpaceState(output, focused_workspace, focused_window, mode)


def move_node_to_workspace(
    aerospace_socket: AerospaceSocket,
    workspace_number: int,
    window_id: str,
    follow: bool,
):
    aerospace_socket.send(
        [
            "move-node-to-workspace",
            str(workspace_number),
            "--window-id",
            str(window_id),
        ]
        + (["--focus-follows-window"] if follow else []),
    )


def reset_window(aerospace_socket: AerospaceSocket, new_window: bool):
    state = query_state(aerospace_socket)

    if state.focused_window is None or state.focused_workspace is None:
        raise ValueError("No focused window or workspace")

    if (
        state.workspaces[state.focused_workspace].windows[state.focused_window].name
        in ban_list
    ):
        raise ValueError("Window is in ban list")

    to_merge = new_window and state.mode == "merge"

    if to_merge:
        return

    next_workspace = next(new_valid_space(state.workspaces))

    move_node_to_workspace(aerospace_socket, next_workspace, state.focused_window, True)


def process(aerospace_socket: AerospaceSocket):
    state = query_state(aerospace_socket)

    for i, (old_workspace, workspace) in enumerate(sorted(state.workspaces.items())):
        new_workspace = i + 1

        if new_workspace != old_workspace:
            for _, window in workspace.windows.items():
                move_node_to_workspace(
                    aerospace_socket, new_workspace, window.id, window.focused
                )


def yank(aerospace_socket: AerospaceSocket):
    state = query_state(aerospace_socket)
    with open("/tmp/aerospace_window", "w") as f:
        if state.focused_window:
            f.write(str(state.focused_window))


def paste(aerospace_socket: AerospaceSocket):
    with open("/tmp/aerospace_window") as f:
        state = query_state(aerospace_socket)

        if state.focused_workspace:
            move_node_to_workspace(
                aerospace_socket, state.focused_workspace, f.readline(), False
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
                    reset_window(aerospace_socket, new_window=True)
                    conn.sendall(b"OK")
                case "reset":
                    reset_window(aerospace_socket, new_window=False)
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
