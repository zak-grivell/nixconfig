{ pkgs, ... }:
{
  home.packages = with pkgs; [
    uv
    ty
    ruff
    python314
  ];
}
