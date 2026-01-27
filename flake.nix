{
  description = "Zak's Nix Environment";

  inputs = {
    allfollow.url = "github:spikespaz/allfollow";
    flake-file.url = "github:vic/flake-file";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    imports = [
        (inputs.import-tree ./modules)
      ];
  };
}
