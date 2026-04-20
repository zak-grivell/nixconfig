{inputs, ...}: let
  host = "aarch64-darwin";
in {
  flake-file.inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.darwin.system = {config, ...}: {
    imports = [
      inputs.home-manager.darwinModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.zakgrivell.imports = [
      inputs.self.homeModules.default
    ];
  };

  flake.homeModules.default = {
    pkgs,
    inputs,
    ...
  }: {
    home.username = "zakgrivell";
    home.stateVersion = "26.05";
  };
}
