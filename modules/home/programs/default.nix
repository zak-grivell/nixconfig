{ pkgs, ... }:
{
  imports = [
    ./fastfetch.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./yazi.nix
    ./zellij.nix
    ./nushell.nix
    ./nvim.nix
    ./direnv.nix
    ./devenv.nix
  ];

  programs = {
    fzf.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
  };

  home.packages = with pkgs; [ gemini-cli ];
}
