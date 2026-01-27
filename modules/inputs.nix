{ inputs, ...}: {
  imports = [
     inputs.flake-file.flakeModules.default # flake-file options.
    ];

  flake-file = {
      inputs = {
        flake-file.url = "github:vic/flake-file";
        allfollow.url = "github:spikespaz/allfollow";
        systems.url = "github:nix-systems/default";
        treefmt-nix.url = "github:numtide/treefmt-nix";
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      };
      nixConfig = { };
      description = "Zak's nix configuration";
    };
}
