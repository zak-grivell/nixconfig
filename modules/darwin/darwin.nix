{ inputs, ... }: let
  user = "zakgrivell";
  name = "zakbook";
in {
  flake-file.inputs.nix-darwin.url = "github:LnL7/nix-darwin";


  flake.darwinConfigurations.zakbook = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.self.modules.darwin.zakbook
    ];
  };

  flake.modules.darwin.system = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = name;
    nixpkgs.config.allowUnfree = true;

    system.primaryUser = user;
    system.stateVersion = 6;

  };

}
