# See /modules/darwin/* for actual settings
# This file is just *top-level* configuration.
{
  flake,
  lib,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "zakbook";

  system.primaryUser = "zakgrivell";
  #
  # Note that home-manager is not very smart, if this backup file already exists it
  # will complain "Existing file .. would be clobbered by backing up". To mitigate this,
  # we try to use as unique a backup file extension as possible.
  home-manager.backupFileExtension = "nixos-unified-template-backup";

  nix-homebrew.user = "zakgrivell";
  nix-homebrew.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # system.autoUpgrade = {
  #   enable = true;
  #   dates = "daily";
  # };

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

  # Set nixbld group GID to match actual system value
  ids.gids.nixbld = 350;
}
