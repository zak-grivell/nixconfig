{ config, ... }:
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
          name = config.me.fullname;
          email = config.me.email;
        };
        aliases = {
          ci = "commit";
        };
      };
    };
    lazygit.enable = true;
  };

}
