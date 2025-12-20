{ pkgs, ... }:
let
  aeroServer = pkgs.writeScriptBin "aero-server" ''
    #!${pkgs.python311}/bin/python3
    # Nix will embed your script content right here

    #!/usr/bin/env python3

    import socket
    import os
    import subprocess
    from dataclasses import dataclass, field
    from collections import defaultdict
    from pathlib import Path

    socket_dir = Path.home() / ".local" / "run"
    socket_dir.mkdir(parents=True, exist_ok=True)

    SOCKET_PATH = str(socket_dir / "aerospace-manager.sock")

    # Remove old socket
    if os.path.exists(SOCKET_PATH):
        os.unlink(SOCKET_PATH)


    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.bind(SOCKET_PATH)
    sock.listen(1)

    print("Aerospace UNIX server started at", SOCKET_PATH)



    @dataclass
    class Window:
        id: str
        focused: bool


    @dataclass
    class Workspace:
        windows: list[Window] = field(default_factory=list)
        focused: bool = False


    def get_data() -> dict[str, Workspace]:
        workspaces: dict[str, Workspace] = defaultdict(lambda: Workspace())

        out = subprocess.run(
            [
                "aerospace",
                "list-windows",
                "--all",
                "--format",
                '%{workspace} %{window-id} %{workspace-is-focused}',
            ],
            capture_output=True,
            text=True,
        )

        print("out:", out.stdout, out.args)

        for workspace, wid, focused in [line.split() for line in out.stdout.splitlines()]:
            print(workspace, wid, focused)
            workspaces[workspace].windows.append(Window(wid, bool(focused)))
            if bool(focused):
                workspaces[workspace].focused = True

        return workspaces

    def get_current_workspace(
        data: dict[str, Workspace],
    ) -> tuple[str, Workspace] | tuple[None, None]:
        for name, workspace in data.items():
            if workspace.focused:
                return name, workspace

        return None, None


    def get_focused_window(data: dict[str, Workspace]) -> Window | None:
        _, focused_workspace = get_current_workspace(data)

        if focused_workspace is None:
            return None

        for window in focused_workspace.windows:
            if window.focused:
                return window


    def move_window_to_workspace(workspace_name: str, window: Window, follow=False):
        print(f"moving window {window.id} to {workspace_name}")

        subprocess.Popen(
            (
                [
                    "aerospace",
                    "move-node-to-workspace",
                    str(workspace_name),
                    "--window-id",
                    window.id,
                ]
            )
            + (["--focus-follows-window"] if follow else [])
        )


    def reset_window():
        data = get_data()

        window = get_focused_window(data)

        print(list(data.items()))

        if window is None:
            print("reset-window: err no window selected")
            return

        workspaces = data.keys()

        valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

        gen = new_valid_space(valid)

        move_window_to_workspace(workspace_name=str(next(gen)), window=window, follow=True)


    def process():
        data = get_data()

        workspaces = data.keys()

        valid = {int(workspace) for workspace in workspaces if workspace.isdigit()}

        gen = new_valid_space(valid)

        while (n := next(gen)) != len(valid) + 1:
            spot = next_valid_spot(valid, n)

            for window in data[str(spot)].windows:
                move_window_to_workspace(n, window, follow=window.focused)

            valid.remove(spot)
            valid.add(n)


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


    def yank():
        data = get_data()
        with open("/tmp/aerospace_window", "w") as f:
            window = get_focused_window(data)

            if window:
                f.write(window.id)


    def paste():
        with open("/tmp/aerospace_window") as f:
            data = get_data()

            workspace, _ = get_current_workspace(data)

            if workspace:
                move_window_to_workspace(workspace, Window(f.readline(), True))


    while True:
        conn, _ = sock.accept()
        data = conn.recv(1024).decode("utf-8").strip()

        try:
            match data:
                case "process":
                    process()
                    conn.sendall(b"OK")
                case "new-window":
                    reset_window()
                    conn.sendall(b"OK")
                case "yank":
                    yank()
                    conn.sendall(b"OK")
                case "paste":
                    paste()
                    conn.sendall(b"OK")
                case _:
                    conn.sendall(b"ERR unknown command")
        except Exception as e:
            conn.sendall(f"ERR {e}".encode())

        conn.close()
  '';
in
{
  home.packages = [ aeroServer ];

  home.launchd.agents.aero-manager-server = {
    enable = true;
    config = {
      ProgramArguments = [ "${aeroServer}/bin/aero-server" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/aeroserver.log";
      StandardErrorPath = "/tmp/aeroserver.err";
    };
  };
}
