{ pkgs, ... }:
let
  # Even more lightweight version using launchd's built-in file watching
  plist-watcher = pkgs.writeShellScriptBin "plist-watcher" ''
    #!/bin/zsh

    SPECIALISATION_PATH="/tmp/specialisation_path"
    HM_PATH=$(cat "$SPECIALISATION_PATH" 2>/dev/null | tr -d '\n')

    [[ -z "$HM_PATH" ]] && { echo "Error: Cannot read specialisation path"; exit 1; }

    theme=$(osascript <<EOF
    tell application "System Events"
        tell appearance preferences
            set dark_mode to dark mode
        end tell
    end tell

    if dark_mode then
        return "Dark"
    else
        return "Light"
    end if
    EOF
    )

    if [ "$theme" == "Dark" ]; then
        "$HM_PATH/dark/activate"
    else
        "$HM_PATH/light/activate"
    fi

    # Signal helix
    pkill -USR1 hx 2>/dev/null || true
  '';
in {
  environment.systemPackages = [
    plist-watcher
  ];

  # system.activationScripts.init_theme.text = "${plist-watcher}/bin/plist-watcher";

  system.activationScripts.postActivation = {
    enable = true;
    text = ''
      realpath /Users/zakgrivell/.local/state/nix/profiles/home-manager/specialisation > /tmp/specialisation_path
    '';
  };


  # Option 2: Ultra-lightweight using launchd's WatchPaths (most efficient)
  launchd.user.agents.plist-watcher = {
    serviceConfig = {
      ProgramArguments = ["${plist-watcher}/bin/plist-watcher"];
      WatchPaths = [
        "/Users/zakgrivell/Library/Preferences/.GlobalPreferences.plist"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/plist-watcher.err";
      StandardOutPath = "/tmp/plist-watcher.out";
    };
  };
}
