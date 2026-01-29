{ pkgs, lib, inputs, ... }: {
  flake.darwinConfigurations.zakbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.self.modules.darwin.system
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.users.zakgrivell.imports = [
          inputs.self.homeModules.default
          inputs.zen-browser.homeModules.beta
        ];
      }
    ];
  };
}
