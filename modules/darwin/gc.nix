{ ... }: {
  flake.modules.darwin.system.gc = {
    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 1d";
    };

    nix.optimise.automatic = true;
  };
}
