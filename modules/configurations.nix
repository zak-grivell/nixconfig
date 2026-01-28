{ inputs, ... }: {
  flake.darwinConfigurations.zakbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.self.modules.darwin.system
    ];
  };

  flake.homeConfigurations.zakgrivell = inputs.home-manager.lib.homeManagerConfiguration {
      modules = [
        inputs.self.modules.homeManager.home
      ];
  };
}
