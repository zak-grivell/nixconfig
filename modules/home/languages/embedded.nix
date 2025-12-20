{ pkgs, ... }:
{
  home.package = with pkgs; [
    platformio
  ];
}
