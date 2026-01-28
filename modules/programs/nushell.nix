{ ... }: {
  flake.modules.darwin.system = { pkgs, ... }: {
      environment.shells = [
        pkgs.nushell
        pkgs.bash
      ];

      users.users.zakgrivell = {
        shell = pkgs.nushell;
      };
  };

  flake.homeModules.default = {
    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.PATH = ($env.PATH | split row (char esep))
      '';
    };
  };
}
