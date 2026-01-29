{ ... }: {
  flake.modules.darwin.system = { pkgs, ... }: {
      environment.shells = [
        pkgs.nushell
        pkgs.zsh
      ];

      users.users.zakgrivell = {
        shell = pkgs.zsh;
      };

      programs.zsh.interactiveShellInit = ''
          if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
            exec nu
          fi
      '';
  };

  flake.homeModules.default = {
    programs.nushell = {
      enable = true;

      envFile.text = ''
          $env.PATH = ($env.PATH | split row (char esep) | append '($home)/.nix-profile/bin' | uniq)
        '';
    };
  };
}
