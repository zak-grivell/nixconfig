{...}: {
  flake.modules.darwin.system = {pkgs, ...}: {
    programs.fish.enable = true;

    environment.shells = [
      pkgs.fish
      pkgs.zsh
      pkgs.xonsh
    ];

    users.users.zakgrivell.shell = pkgs.fish;
  };

  flake.homeModules.default = {pkgs, ...}: {
    home.packages = [pkgs.pokeget-rs pkgs.fastfetch pkgs.xonsh];

    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish = {
      enable = true;

      shellInit = ''
        fish_add_path --path --prepend "$HOME/Library/Application Support/carapace/bin"
        fish_add_path --path --append "$HOME/.nix-profile/bin" /opt/homebrew/bin
      '';

      interactiveShellInit = ''
        set -g fish_greeting
        pokeget random --hide-name | fastfetch --file-raw -
      '';

      functions.list_on_directory_change = {
        onVariable = "PWD";
        body = ''
          if status is-interactive
            ls
          end
        '';
      };

      shellAliases = {
        gcm = "git commit -m";
        ga = "git add .";
        gs = "git status";
        gp = "git push";
      };
    };
  };
}
