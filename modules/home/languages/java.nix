{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jdk25
  ];
}
