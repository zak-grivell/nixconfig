{ pkgs, ... }:
let
  server_command =
    command:
    ''exec-and-forget /bin/bash -c "echo "${command}" | socat - UNIX-CONNECT:/tmp/aeroserver.sock"'';
in
{
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    config = ./skhdrc;
  };
}
