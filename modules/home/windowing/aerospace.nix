{ pkgs, ... }:
let

  aerospace = pkgs.callPackage ../../pkgs/aerospace.nix { };

in
{
  home.packages = with pkgs; [
    socat
    aerospace
  ];

  programs.aerospace = {
    enable = true;

    package = aerospace;

    launchd.enable = true;

    settings = {
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
      ];

      on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change"
        "exec-and-forget aero-client process"
      ];

      on-window-detected = [
        {
          run = "exec-and-forget aero-client new-window";
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
        alt-r = "exec-and-forget aero-client new-window";
        alt-x = "close --quit-if-last-window";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        shift-alt-h = "move left";
        shift-alt-j = "move down";
        shift-alt-k = "move up";
        shift-alt-l = "move right";

        alt-p = "exec-and-forget aero-client paste";
        alt-y = "exec-and-forget aero-client yank";

        alt-t = ''exec-and-forget open -a "Ghostty.app" '';
        alt-b = ''exec-and-forget open -a "Zen.app" '';
        alt-d = ''exec-and-forget open -a "Finder.app" '';
        alt-e = ''exec-and-forget open -a "Zed.app" '';
        alt-n = ''exec-and-forget open -a "Obsidian.app" '';

        alt-shift-t = ''exec-and-forget open -a "Ghostty.app" -n '';
        alt-shift-b = ''exec-and-forget open -a "Zen.app" -n '';
        alt-shift-d = ''exec-and-forget open -a "Finder.app" -n '';
        alt-shift-e = ''exec-and-forget open -a "Zed.app" -n '';
        alt-shift-n = ''exec-and-forget open -a "Obsidian.app" -n '';

        alt-u = "layout floating tiling";
        alt-f = "fullscreen";

        alt-minus = "resize smart -100";
        alt-equal = "resize smart +100";

        alt-o = "workspace next --wrap-around";
        alt-i = "workspace prev --wrap-around";

        alt-s = "exec-and-forget sketchybar --reload";
        alt-c = "reload-config";
        alt-a = "layout accordion horizontal vertical";
        alt-g = "layout tiles horizontal vertical";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
      };
    };
  };
}
