{
  flake.homeModules.default = let
    githubToken = builtins.replaceStrings ["\n"] [""] (builtins.readFile /Users/zakgrivell/config/secrets/github);
  in {
    home.shellAliases = {
      g = "git";
      lg = "lazygit";
    };

    home.sessionVariables = {
      GITHUB_TOKEN = githubToken;
    };

    programs = {
      git = {
        enable = true;
        ignores = ["*~" "*.swp" ".DS_store" ".devenv" ".settings" ".devenv.flake.nix" ".envrc" ".direnv"];
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
      lazygit = {
        enable = true;
        enableNushellIntegration = true;
      };

      gh.enable = true;
    };
  };
}
