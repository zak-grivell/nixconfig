{ pkgs, lib, ... }:
let
  switch_mode = mode: [
    "mode ${mode}"
    "exec-and-forget sketchybar --trigger aerospace_mode_change MODE=${mode}"
  ];

  aeroserver = command: [
    ''exec-and-forget /bin/bash -c "echo "${command}" | socat - UNIX-CONNECT:/tmp/aeroserver.sock"''
  ];
in
{
  home.packages = with pkgs; [ socat ];

  programs.aerospace = {
    enable = true;

    launchd.enable = true;

    settings = {
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change"
      ]
      ++ aeroserver "process";

      on-window-detected = [
        {
          run = aeroserver "new-window";
        }
      ];

      config-version = 2;

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

      persistent-workspaces = [ ];

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
        r = aeroserver "new-window" ++ switch_mode "main";
        # close apps
        x = [ "close --quit-if-last-window" ] ++ switch_mode "main";

        # changing focus
        h = [ "focus left" ] ++ switch_mode "main";
        j = [ "focus down" ] ++ switch_mode "main";
        k = [ "focus up" ] ++ switch_mode "main";
        l = [ "focus right" ] ++ switch_mode "main";

        # moving windows between workspaces
        y = aeroserver "yank" ++ switch_mode "main";
        p = aeroserver "paste" ++ switch_mode "main";

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
              ''workspace ${n}''
            ]
            ++ switch_mode "main"
          );
    };
  };
}
