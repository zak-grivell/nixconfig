{ inputs, config, lib, ... }: let
  user = "zakgrivell";
  name = "zakbook";

  mkDarwin = system: name: let
      hostModule = config.flake.modules.hosts.${name};
      specialArgs = {
        inherit inputs;
        hostConfig = hostModule // {name = name;};
      };
    in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules =
          hostModule.imports
          ++ [
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              # networking.hostName = lib.mkDefault name;
              nixpkgs.hostPlatform = lib.mkDefault system;
              nixpkgs.config.allowUnfree = true;
              system.stateVersion = 6;
            }
          ];
      };
in {
  flake-file.inputs.nix-darwin.url = "github:LnL7/nix-darwin";

  flake.darwinConfigurations = {
    zakbook = mkDarwin "aarch64-darwin";
    # mordred = darwin-arm "mordred";
  };

  flake.modules.darwin.system = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = name;
    nixpkgs.config.allowUnfree = true;

    system.primaryUser = user;
  };

}
