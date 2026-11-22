{inputs, ...}: {
  flake.nixosConfigurations.zakpc = inputs.nixpkgs.lib.nixosSystem {
    modules = [inputs.self.modules.nixos.zakpc];
  };

  flake.darwinConfigurations.zakbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.self.modules.darwin.system
    ];
  };
}
