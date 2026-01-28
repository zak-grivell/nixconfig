{
  flake.homeModules.default = { config, ... }:
  {
    home.shellAliases = {
      g = "git";
      lg = "lazygit";
    };

    # https://nixos.asia/en/git
    programs = {
      git = {
        enable = true;
          ignores = [ "*~" "*.swp" ".DS_store"];
        settings = {
          user = {
            name = "zak grivell";
            email = "zak@grivell.uk";
          };
          aliases = {
            ci = "commit";
          };
        };
      };
      lazygit.enable = true;
    };

  }


}
