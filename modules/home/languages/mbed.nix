{ pkgs, ... }:
{
  home.packages = with pkgs; [
    python313Packages.cmake
    python313Packages.pip
    python313Packages.ninja
    gcc-arm-embedded
  ];
}
