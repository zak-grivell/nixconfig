{ pkgs, ... }:
{
  imports = [
    ./ghostty.nix
    ./obsidian.nix
    ./zed.nix
    ./discord.nix
    ./godot.nix
  ];

  home.packages = with pkgs; [
    discord
    obsidian
    godot
    kicad
    ghdl
    orca-slicer
  ];
}
