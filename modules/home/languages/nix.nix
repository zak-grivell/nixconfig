{ pkgs, ... }:
{
  home.packages = with pkgs; [
    omnix
    nixd
    cachix
    nil # Nix language server
    nix-info
    nixpkgs-fmt
    manix
  ];
}
