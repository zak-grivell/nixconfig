{ inputs, ...}: {
  imports = [
     inputs.flake-file.flakeModules.default # flake-file options.
    ];

  inputs = {

  };

  flake-file = {
      inputs = {
        flake-file.url = "github:vic/flake-file";
        allfollow.url = "github:spikespaz/allfollow";
        systems.url = "github:nix-systems/default";
        treefmt-nix.url = "github:numtide/treefmt-nix";
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nix-darwin.url = "github:LnL7/nix-darwin";
        home-manager.url = "github:nix-community/home-manager";
      };
      nixConfig = { }; # if you had any.
      description = "Your flake description";
    };


}
