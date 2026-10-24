{...}: {
  flake.modules.darwin.system = {pkgs, ...}: {
    environment.shells = [
      pkgs.nushell
      pkgs.zsh
      pkgs.xonsh
    ];

    users.users.zakgrivell = {
      shell = pkgs.zsh;
    };
  };

  flake.homeModules.default = {pkgs, ...}: {
    home.packages = [pkgs.pokeget-rs pkgs.fastfetch pkgs.xonsh];

    programs.carapace = {
      enable = true;
      # Use the named completion inputs introduced in Nushell 0.116.
      enableNushellIntegration = false;
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.nushell = {
      enable = true;

      environmentVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };

      extraConfig = ''
        $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/Library/Application Support/carapace/bin" | uniq)

        $env.config.completions.external.completer = {|place|
          load-env {
            CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq | str join "\n")
            CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq | str join "\n")
          }

          carapace $place.command.0 nushell ...$place.command | from json
        }

        $env.config = ($env.config | upsert hooks.env_change.PWD [{|before, after| ls }])
      '';

      shellAliases = {
        gcm = "git commit -m";
        ga = "git add .";
        gs = "git status";
        gp = "git push";
      };

      envFile.text = ''
          if $nu.is-interactive {
            pokeget random --hide-name | fastfetch --file-raw -
          }

          $env.PATH = ($env.PATH | split row (char esep) | append '($home)/.nix-profile/bin' | append '/opt/homebrew/bin' | uniq)

          $env.config.show_banner = false
      '';
    };
  };
}
