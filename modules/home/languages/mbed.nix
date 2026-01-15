{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  home.packages = [
    pkgs.python313Packages.cmake
    pkgs.python313Packages.pip
    pkgs.python313Packages.ninja
    pkgs.gcc-arm-embedded
    self.packages.${pkgs.system}.mbed-tools
  ];
}
