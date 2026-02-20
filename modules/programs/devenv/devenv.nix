{ ... }:

{
  flake.homeModules.default = { pkgs, ... }: {
    home.packages = [
      pkgs.devenv

      (
        pkgs.writeScriptBin "template" ''
          #!${pkgs.python3}/bin/python3 -u
          
          TEMPLATES_PATH  = "${./_templates}"
          ${builtins.readFile ./templates.py}
        ''
      )
    ];
    
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
      silent = true;
    };
  };
}
