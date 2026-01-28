# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Zak's nix configuration";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";

    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:LnL7/nix-darwin";

    nixvim.url = "github:nix-community/nixvim";
  };
}
