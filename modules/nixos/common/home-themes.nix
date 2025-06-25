{ pkgs, ... }:
let
  # Even more lightweight version using launchd's built-in file watching
  plist-watcher = pkgs.writeShellScriptBin "plist-watcher" ''
    #!/bin/zsh

    SPECIALISATION_PATH="/tmp/specialisation_path"
    HM_PATH=$(cat "$SPECIALISATION_PATH" 2>/dev/null | tr -d '\n')

    [[ -z "$HM_PATH" ]] && { echo "Error: Cannot read specialisation path"; exit 1; }

    mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

    if [[ "$mode" == "Dark" ]]; then
        exec "$HM_PATH/dark/activate"
    else
        exec "$HM_PATH/light/activate"
    fi

    # Signal helix
    pkill -USR1 hx 2>/dev/null || true
  '';
in {
  environment.systemPackages = [
    plist-watcher
  ];

  a.fake.option = "fake value";

  # system.activationScripts.init_theme.text = "${plist-watcher}/bin/plist-watcher";

  system.activationScripts.set_theme_path = {
    enable = true;
    text = ''
      echo "Setting PATH..." >> /tmp/debug_activation.log
      realpath /Users/zakgrivell/.local/state/nix/profiles/home-manager/specialisation > /tmp/specialisation_path
      echo "Done." >> /tmp/debug_activation.log
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
