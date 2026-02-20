# modules/inputs.nix
{ inputs, ... }:
{
  imports = [
   inputs.flake-file.flakeModules.default # flake-file options.
  ];
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      systems.url = "github:nix-systems/default";
    };
    nixConfig = { };
    description = "Zak's nix configuration";
  };
}
