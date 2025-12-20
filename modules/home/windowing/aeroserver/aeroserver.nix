{ pkgs, ... }:
let
  aeroServer = pkgs.writeScriptBin "aero-server" ''
    #!${pkgs.python311}/bin/python3 -u
    ${builtins.readFile ./areo-manager.py}
  '';
in
{
  home.packages = [ aeroServer ];

  launchd.agents.aero-manager = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "echo 'Starting ${aeroServer}' && ${aeroServer}/bin/aero-server"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/aero-manager.log";
      StandardErrorPath = "/tmp/aero-manager.error.log";
    };
  };
}
