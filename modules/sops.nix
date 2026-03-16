{
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
  };


    flake.modules.darwin.system = {inputs, ...}: {
      modules = [ inputs.sops-nix.darwinModules.sops ];
    };
}
