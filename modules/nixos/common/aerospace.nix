{ lib, ... }:
let
  switch_mode = mode: [
    "mode ${mode}"
    "exec-and-forget sketchybar --trigger aerospace_mode_change MODE=${mode}"
  ];
in
{
  environment.etc = {
    "aerospace/move-from-temp.bash".text = ''
      # Get the workspace of the currently focused window
      current_workspace=$(aerospace list-windows --focused --format '%{workspace}')

      # Get the window ID of the currently focused window
      focused_window_id=$(od -An -N8 -tu8 < /dev/urandom | tr -d ' ')

      # If the current workspace is "temp", move the focused window to its workspace
      if [ "$current_workspace" = "temp" ]; then
        aerospace move-node-to-workspace "$focused_window_id" --focus-follows-window
      fi
    '';

    "aerospace/new_workspace.bash".text = ''
      # Get the workspace of the currently focused window
      current_workspace=$(aerospace list-windows --focused --format '%{workspace}')

      # Get the window ID of the currently focused window
      focused_window_id=$(od -An -N8 -tu8 < /dev/urandom | tr -d ' ')

      aerospace move-node-to-workspace "$focused_window_id" --focus-follows-window
    '';

    "aerospace/startup.bash".text = ''
      for wid in $(aerospace list-windows --all --format '%{window-id}'); do
          # Get the workspace of the currently focused window
          current_workspace=$(aerospace list-windows --focused --format '%{workspace}')

          # Generate a "random enough" workspace ID
          workspace=$(od -An -N8 -tu8 < /dev/urandom | tr -d ' ')

          # Move the window to the generated workspace
          aerospace move-node-to-workspace "$workspace" --window "$wid"
      done
    '';

    "aerospace/workspace.bash".text = ''
      n="$1"

      workspace="$(aerospace list-workspaces --monitor focused | sed "$(echo $n)q;d")"

      # If no workspace at that index, define a fallback name and let move create it
      if [ -z "$workspace" ]; then
          workspace=$(aerospace list-windows --focused --format '%{window-id}')
      fi

      # Move focused window to target workspace, focus follows
      aerospace workspace $workspace
    '';

    "aerospace/yank.bash".text = ''
      aerospace list-windows --focused --format '%{window-id}' > /tmp/aerospace_window
    '';

    "aerospace/place.bash".text = ''
      set -x current_workspace $(aerospace list-windows --focused --format '%{workspace}')

      set -x wid $(cat /tmp/aerospace_window)
      aerospace move-node-to-workspace --window-id "$wid" "$current_workspace"

    '';
  };

  services.aerospace = {
    enable = true;
    settings = {
      after-startup-command = [
        "exec-and-forget bash /etc/aerospace/startup.bash"
      ];

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change"
        "exec-and-forget bash /etc/aerospace/move-from-temp.bash"
      ];

      on-window-detected = [
        {
          check-further-callbacks = true;
          "if" = {
            app-name-regex-substring = "^(?!Security Agent$).+$";
          };
          run = [
            "move-node-to-workspace temp --focus-follows-window"
          ];
        }
      ];

      start-at-login = false;

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 100;

      default-root-container-layout = "tiles";

      default-root-container-orientation = "auto";

      automatically-unhide-macos-hidden-apps = false;

      exec = {
        inherit-env-vars = true;

        env-vars = {
          PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${HOME}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:\${PATH}:/etc/profiles/per-user/zakgrivell/bin:/nix/var/nix/profiles/system/sw/bin/";
        };
      };

      key-mapping = {
        preset = "qwerty";
      };

      gaps = {
        inner = {
          horizontal = 25;
          vertical = 25;
        };
        outer = {
          left = 25;
          bottom = 25;
          top = [
            { monitor."Built-in Retina Display" = 15; }
            60
          ];
          right = 25;
        };
      };

      mode.main.binding = {
        f18 = switch_mode "normal";
      };

      mode.normal.binding = {
        esc = switch_mode "main";
        backspace = switch_mode "main";

        # reset workspace
        r = [ ''exec-and-forget bash /etc/aerospace/new_workspace.bash'' ];

        # close apps
        x = [ "close --quit-if-last-window" ] ++ switch_mode "main";

        # changing focus
        h = [ "focus left" ] ++ switch_mode "main";
        j = [ "focus down" ] ++ switch_mode "main";
        k = [ "focus up" ] ++ switch_mode "main";
        l = [ "focus right" ] ++ switch_mode "main";

        # moving windows between workspaces
        y = [ ''exec-and-forget fish /etc/aerospace/yank.bash'' ] ++ switch_mode "main";
        p = [
          ''exec-and-forget fish /etc/aerospace/place.bash > /tmp/aerospace_exec.out 2> /tmp/aerospace_exec.err''
        ]
        ++ switch_mode "main";

        # relocating in workspace
        shift-j = [ "move down" ] ++ switch_mode "main";
        shift-k = [ "move up" ] ++ switch_mode "main";
        shift-h = [ "move left" ] ++ switch_mode "main";
        shift-l = [ "move right" ] ++ switch_mode "main";

        # Apps
        t = [ "exec-and-forget open -a 'Ghostty.app'" ] ++ switch_mode "main";
        b = [ "exec-and-forget open -a 'Zen.app'" ] ++ switch_mode "main";
        d = [ "exec-and-forget open -a 'Finder.app'" ] ++ switch_mode "main";
        e = [ "exec-and-forget open -a 'Zed.app'" ] ++ switch_mode "main";
        n = [ "exec-and-forget open -a 'Obsidian.app'" ] ++ switch_mode "main";

        # New app window
        shift-t = [ "exec-and-forget open -a 'Ghostty.app' -n" ] ++ switch_mode "main";
        shift-b = [ "exec-and-forget open -a 'Zen.app' -n" ] ++ switch_mode "main";
        shift-d = [ "exec-and-forget open -a 'Finder.app' -n" ] ++ switch_mode "main";
        shift-e = [ "exec-and-forget open -a 'Zed.app' -n" ] ++ switch_mode "main";

        u = [ "layout floating tiling" ] ++ switch_mode "main";
        f = [ "fullscreen" ] ++ switch_mode "main";

        # sizing
        minus = [ "resize smart -100" ] ++ switch_mode "main";
        equal = [ "resize smart +100" ] ++ switch_mode "main";

        # workspace moving
        o = [ "workspace next --wrap-around" ] ++ switch_mode "main";
        i = [ "workspace prev --wrap-around" ] ++ switch_mode "main";

        # config settings
        s = [ "exec-and-forget sketchybar --reload" ] ++ switch_mode "main";
        c = [ "reload-config" ] ++ switch_mode "main";
        a = [ "layout accordion horizontal vertical" ] ++ switch_mode "main";
        g = [ "layout tiles horizontal vertical" ] ++ switch_mode "main";
      }
      //
        lib.genAttrs
          [
            "1"
            "2"
            "3"
            "4"
            "5"
            "6"
            "7"
            "8"
            "9"
          ]
          (
            n:
            [
              ''exec-and-forget bash /etc/aerospace/workspace.bash ${n}''
            ]
            ++ switch_mode "main"
          );
    };
  };
}
