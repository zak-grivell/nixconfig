let
  key_bindings = {
    alt-x = "close --quit-if-last-window";
    alt-t = ''exec-and-forget open -a "Ghostty.app" '';
    alt-b = ''exec-and-forget open -a "Helium.app" '';
    alt-d = ''exec-and-forget open -a "Finder.app" '';
    alt-e = ''exec-and-forget open -a "Zed.app" '';

    alt-shift-t = ''exec-and-forget open -a "Ghostty.app" -n '';
    alt-shift-b = ''exec-and-forget open -a "Helium.app" -n '';
    alt-shift-d = ''exec-and-forget open -a "Finder.app" -n '';
    alt-shift-e = ''exec-and-forget open -a "Zed.app" -n '';

    alt-u = "layout floating tiling";

    alt-o = "workspace next --wrap-around";
    alt-i = "workspace prev --wrap-around";

    alt-1 = "workspace 1";
    alt-2 = "workspace 2";
    alt-3 = "workspace 3";
    alt-4 = "workspace 4";
    alt-5 = "workspace 5";
    alt-6 = "workspace 6";
    alt-7 = "workspace 7";
    alt-8 = "workspace 8";
    alt-9 = "workspace 9";

    alt-shift-1 = "move-node-to-workspace 1 --focus-follows-window";
    alt-shift-2 = "move-node-to-workspace 2 --focus-follows-window";
    alt-shift-3 = "move-node-to-workspace 3 --focus-follows-window";
    alt-shift-4 = "move-node-to-workspace 4 --focus-follows-window";
    alt-shift-5 = "move-node-to-workspace 5 --focus-follows-window";
    alt-shift-6 = "move-node-to-workspace 6 --focus-follows-window";
    alt-shift-7 = "move-node-to-workspace 7 --focus-follows-window";
    alt-shift-8 = "move-node-to-workspace 8 --focus-follows-window";
    alt-shift-9 = "move-node-to-workspace 9 --focus-follows-window";

    cmd-space = "exec-and-forget app-menu";
    alt-space = "exec-and-forget window-menu";
  };
in {
  flake.modules.darwin.system = {
    homebrew = {
      casks = ["alt-tab" "numi"];
      taps = [
        "sadiksaifi/tap"
      ];

      brews = [
        "mac-menu"
      ];
    };
  };

  flake.homeModules.default = {pkgs, ...}: {
    home.packages = with pkgs; [
      socat
      (pkgs.writeShellScriptBin "app-menu" ''
        app=$(
          find /Applications "$HOME/Applications" -maxdepth 1 -name "*.app" 2>/dev/null \
            | sed 's|.*/||; s|\.app$||' \
            | mac-menu
        )

        [ -z "$app" ] && exit 0

        open -a "$app"
      '')
      (pkgs.writeShellScriptBin "window-menu" ''
        selected=$(
          aerospace list-windows --all \
            --format '%{window-id} %{app-name} — %{window-title}' \
            | mac-menu
        )

        [ -z "$selected" ] && exit 0

        window_id=$(printf '%s\n' "$selected" | awk '{print $1}')

        aerospace focus --window-id "$window_id"
      '')
    ];

    programs.aerospace = {
      enable = true;

      launchd.enable = true;

      settings = {
        config-version = 2;
        start-at-login = false;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;

        accordion-padding = 0;

        default-root-container-layout = "accordion";
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

        persistent-workspaces = [];

        gaps = {
          inner = {
            horizontal = 0;
            vertical = 0;
          };
          outer = {
            left = 0;
            bottom = 0;
            top = 0;
            right = 0;
          };
        };

        mode.main.binding = key_bindings;
      };
    };
  };
}
