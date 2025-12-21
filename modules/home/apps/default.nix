{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    discord
    obsidian
  ];
}
