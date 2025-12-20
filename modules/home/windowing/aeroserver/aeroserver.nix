{ pkgs, ... }:
let
  aeroServer = pkgs.writeScriptBin "aero-server" ''
    #!${pkgs.python311}/bin/python3 -u
    ${builtins.readFile scripts/areo-manager.py}
  '';
in
{
  home.packages = [ aeroServer ];

  launchd.agents.aero-manager = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "echo 'Starting ${aeroServer}' && ${aeroServer}/bin/aero-server"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/aeroserver.log";
      StandardErrorPath = "/tmp/aeroserver.err";
    };
  };
}
