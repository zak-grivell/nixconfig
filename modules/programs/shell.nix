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
      enableNushellIntegration = true;
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
