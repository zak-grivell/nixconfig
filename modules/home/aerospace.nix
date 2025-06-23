{ flake, pkgs, lib, ... }:

let
  switch_mode = mode: [
    "mode ${mode}"
    "exec-and-forget sketchybar --trigger aerospace_mode_change MODE=${mode}"
  ];

  inherit (flake)  inputs;
  std = inputs.nix-std.lib;
in {
  home.packages = [ pkgs.aerospace ];

  home.file.".config/aerospace/aerospace.toml".text = std.serde.toTOML {
    after-startup-command = [
        "exec-and-forget sketchybar"
        "exec-and-forget borders"
        "exec-and-forget cd aerospace-swipe; make uninstall; make install"
    ];

    exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
    ];

    on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change"
    ];

    start-at-login = true;

    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    accordion-padding = 100;

    default-root-container-layout = "tiles";

    default-root-container-orientation = "auto";

    automatically-unhide-macos-hidden-apps = false;

    exec = {
      inherit-env-vars = true;

      env-vars = {
        PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:\${HOME}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:\${PATH}:/etc/profiles/per-user/zakgrivell/bin";
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
          top = [{ monitor."Built-in Retina Display" = 15; } 60 ];
          right = 25;
        };
    };

    mode.main.binding = {
      f18 = switch_mode "normal";
    };

    mode.normal.binding = {
        m = switch_mode "move";
        w = switch_mode "workspace";
        r= switch_mode "relocate";
        s = switch_mode "send";
        c = switch_mode "config";

        h = "focus left";
        j = "focus down";
        k = "focus up";
        l = "focus right";

        t = "exec-and-forget open -a 'Ghostty.app'";
        b = "exec-and-forget open -a 'Zen.app'";
        d = "exec-and-forget open -a 'Finder.app'";
        e = "exec-and-forget open -a 'Zed.app'";

        shift-t = "exec-and-forget open -a 'Ghostty.app' -n";
        shift-b = "exec-and-forget open -a 'Zen.app' -n";
        shift-d = "exec-and-forget open -a 'Finder.app' -n";
        shift-e = "exec-and-forget open -a 'Zed.app' -n";

        u = "layout floating tiling";
        f = "fullscreen";

        a = "exec-and-forget open -a 'Launchpad.app'";
        p = ''
        exec-and-forget osascript -e 'tell application "System Events" to key code 49 using {command down}' -e 'delay 1' -e 'tell application "System Events" to key code 21 using {command down}'
        '';
        g = ''
        exec-and-forget osascript -e 'tell application "System Events" to key code 49 using {command down}' -e 'delay 1' -e 'tell application "System Events" to key code 19 using {command down}'
        '';


        minus = "resize smart -100";
        equal = "resize smart +100";

      };

      mode.move.binding = {
        esc = switch_mode "normal";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        j = [ "move down" ] ++ switch_mode "normal";
        k = [ "move up "] ++ switch_mode "normal";
        h = [ "move left "] ++ switch_mode "normal";
        l = [ "move right "] ++ switch_mode "normal";
      };

      mode.workspace.binding = {
        esc = switch_mode "normal";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        j = [ "workspace next --wrap-around" ] ++ switch_mode "normal";
        k = [ "workspace prev --wrap-around" ] ++ switch_mode "normal";
      } // lib.genAttrs [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ] (n: [ "workspace ${n}" ] ++ switch_mode "normal" );

      mode.relocate.binding = {
        esc = switch_mode "normal";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        j = [ "move-node-to-workspace next --wrap-around --focus-follows-window" ] ++ switch_mode "normal";
        k = [ "move-node-to-workspace prev --wrap-around --focus-follows-window" ] ++ switch_mode "normal";
      } // lib.genAttrs [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ] (n: [ "move-node-to-workspace ${n} --focus-follows-window" ] ++ switch_mode "normal" );

      mode.send.binding = {
        esc = switch_mode "normal";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        j = [ "move-node-to-workspace next --wrap-around" ] ++ switch_mode "normal";
        k = [ "move-node-to-workspace prev --wrap-around" ] ++ switch_mode "normal";
      } // lib.genAttrs ["1" "2" "3" "4" "5" "6" "7" "8" "9" ] (n: [ "move-node-to-workspace ${n}" ] ++ switch_mode "normal" );


      mode.config.binding = {
        esc = switch_mode "normal";
        f18 = switch_mode "normal";
        backspace = switch_mode "normal";

        r = [ "reload-config" ] ++ switch_mode "normal";
        a = [ "layout accordion horizontal vertical" ] ++ switch_mode "normal";
        t = [ "layout tiles horizontal vertical" ] ++ switch_mode "normal";
        s = [ "exec-and-forget sketchybar --reload" ] ++ switch_mode "normal";
      };
  };
}
