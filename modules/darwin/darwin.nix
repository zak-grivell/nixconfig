{
  flake-file.inputs = {
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  flake.modules.darwin.system = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "zakbook";
    nixpkgs.config.allowUnfree = true;

    system.primaryUser = "zakgrivell";
    system.stateVersion = 6;
    users.knownUsers = ["zakgrivell"];
    users.users.zakgrivell.uid = 501;

    users.users.zakgrivell = {
      home = "/Users/zakgrivell";
    };

    homebrew.onActivation.cleanup = "uninstall";
    homebrew.onActivation.autoUpdate = true;
  };
}
