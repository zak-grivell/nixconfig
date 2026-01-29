{ ... }: {
  flake.modules.darwin.system = { pkgs, ... }: {
      environment.shells = [
        pkgs.nushell
        pkgs.zsh
      ];

      users.users.zakgrivell = {
        shell = pkgs.zsh;
      };


  };

  flake.homeModules.default = {
    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.PATH = ($env.PATH | split row (char esep))
      '';
    };

    programs.zsh.interactiveShellInit = ''
        if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
          exec nu
        fi
    '';
  };
}
