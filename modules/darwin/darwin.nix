{
  flake.modules.darwin.system = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "zakbook";
    nixpkgs.config.allowUnfree = true;

    system.primaryUser = "zakgrivell";
    system.stateVersion = 6;
    users.knownUsers = [ "zakgrivell" ];
    users.users.zakgrivell.uid = 501;

    users.users.zakgrivell = {
      home = "/Users/zakgrivell";
    };
  };
}
