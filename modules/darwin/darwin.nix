{
  flake.modules.darwin.system = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "zakbook";
    nixpkgs.config.allowUnfree = true;

    system.primaryUser = "zakgrivell";
    system.stateVersion = 6;
  };
}
