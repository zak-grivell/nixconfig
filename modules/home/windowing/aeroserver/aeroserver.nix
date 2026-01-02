{ pkgs, ... }:
let
  aero_server = pkgs.writeScriptBin "aero-server" ''
    #!${pkgs.python311}/bin/python3 -u
    ${builtins.readFile ./areo-manager.py}
  '';

  aero_client = pkgs.writeScriptBin "aero-client" ''
    #!/bin/bash

    echo $1 | socat - UNIX-CONNECT:/tmp/aeroserver.sock
  '';
in
{
  home.packages = [
    aero_server
    aero_client
  ];

  launchd.agents.aero-manager = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "echo 'Starting ${aero_server}' && ${aero_server}/bin/aero-server"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/aero-manager.log";
      StandardErrorPath = "/tmp/aero-manager.error.log";
    };
  };
}
