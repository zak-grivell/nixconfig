{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vhdl-ls
    surfer
  ];
}
