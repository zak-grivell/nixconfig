{ lib, ... }:
let
  switch_mode = mode: [
    "mode ${mode}"
    "exec-and-forget sketchybar --trigger aerospace_mode_change MODE=${mode}"
  ];
in
{
  services.aerospace = {
    enable = true;
    settings = {
      after-startup-command = [
        "exec-and-forget sketchybar"
        # "exec-and-forget borders"
        "exec-and-forget cd aerospace-swipe; make uninstall; make install"
      ];

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change"
        "exec-and-forget bash .config/aerospace.move-from-temp.bash"
      ];

      on-window-detected = [
        {
          check-further-callbacks = true;
          # "if" = {
          #   during-aerospace-startup = true;
          # };
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

        m = switch_mode "move";
        w = switch_mode "workspace";
        r = switch_mode "relocate";
        s = switch_mode "send";
        c = switch_mode "config";

        h = [ "focus left" ] ++ switch_mode "main";
        j = [ "focus down" ] ++ switch_mode "main";
        k = [ "focus up" ] ++ switch_mode "main";
        l = [ "focus right" ] ++ switch_mode "main";

        t = [ "exec-and-forget open -a 'Ghostty.app'" ] ++ switch_mode "main";
        b = [ "exec-and-forget open -a 'Zen.app'" ] ++ switch_mode "main";
        d = [ "exec-and-forget open -a 'Finder.app'" ] ++ switch_mode "main";
        e = [ "exec-and-forget open -a 'Zed.app'" ] ++ switch_mode "main";
        n = [ "exec-and-forget open -a 'Obsidian.app'" ] ++ switch_mode "main";

        shift-t = [ "exec-and-forget open -a 'Ghostty.app' -n" ] ++ switch_mode "main";
        shift-b = [ "exec-and-forget open -a 'Zen.app' -n" ] ++ switch_mode "main";
        shift-d = [ "exec-and-forget open -a 'Finder.app' -n" ] ++ switch_mode "main";
        shift-e = [ "exec-and-forget open -a 'Zed.app' -n" ] ++ switch_mode "main";

        u = [ "layout floating tiling" ] ++ switch_mode "main";
        f = [
          "fullscreen"
        ]
        ++ switch_mode "main";

        p = [
          ''exec-and-forget bash -c '[ "$(aerospace list-windows --focused --format '%{workspace}')" = "temp" ] && aerospace move-node-to-workspace "$(aerospace list-windows --focused --format '%{window-id}')" --focus-follows-window' ''
        ]
        ++ switch_mode "main";

        a = [ "exec-and-forget open -a 'Launchpad.app'" ] ++ switch_mode "main";

        minus = [ "resize smart -100" ] ++ switch_mode "main";
        equal = [ "resize smart +100" ] ++ switch_mode "main";
      };

      mode.move.binding = {
        esc = switch_mode "main";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        j = [ "move down" ] ++ switch_mode "main";
        k = [ "move up" ] ++ switch_mode "main";
        h = [ "move left" ] ++ switch_mode "main";
        l = [ "move right" ] ++ switch_mode "main";
      };

      mode.workspace.binding = {
        esc = switch_mode "main";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        k = [ "workspace next --wrap-around" ] ++ switch_mode "main";
        j = [ "workspace prev --wrap-around" ] ++ switch_mode "main";
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
              ''exec-and-forget bash .config/aerospace/workspace.bash ''
            ]
            ++ switch_mode "main"
          );

      mode.relocate.binding = {
        esc = switch_mode "main";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        k = [ "move-node-to-workspace next --wrap-around --focus-follows-window" ] ++ switch_mode "main";
        j = [ "move-node-to-workspace prev --wrap-around --focus-follows-window" ] ++ switch_mode "main";
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
              ''exec-and-forget bash .config/aerospace/relocate.bash ''
            ]
            ++ switch_mode "main"
          );

      mode.send.binding = {
        esc = switch_mode "main";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        k = [ "move-node-to-workspace next --wrap-around" ] ++ switch_mode "main";
        j = [ "move-node-to-workspace prev --wrap-around" ] ++ switch_mode "main";
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
              ''exec-and-forget bash .config/aerospace/send.bash ''
            ]
            ++ switch_mode "main"
          );

      mode.config.binding = {
        esc = switch_mode "main";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        r = [ "reload-config" ] ++ switch_mode "main";
        a = [ "layout accordion horizontal vertical" ] ++ switch_mode "main";
        t = [ "layout tiles horizontal vertical" ] ++ switch_mode "main";
        s = [ "exec-and-forget sketchybar --reload" ] ++ switch_mode "main";
      };
    };
  };
}
