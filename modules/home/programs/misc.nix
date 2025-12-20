{ pkgs, ... }:
{
  programs = {
    fzf.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
  };
}
