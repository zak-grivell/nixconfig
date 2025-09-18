{ config, lib, ... }:

{
  options = {
    home.programs.homebrewApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Homebrew casks to install via nix-darwin.";
    };
  };

  config = {
    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
      masApps = { };
      casks = config.home.programs.homebrewApps;
    };
  };
}
