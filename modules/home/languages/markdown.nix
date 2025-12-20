{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rumdl
    markdown-oxide
  ];
}
