{...}: {
  flake.homeModules.default = {pkgs, ...}: {
    home.packages = [
      (
        pkgs.writeScriptBin "template" ''
          #!${pkgs.bash}/bin/bash
          set -e

          nix flake init -t github:zak-grivell/templates#$1

          git init
          git add .
          git commit -m "init shell"

          direnv allow
        ''
      )
    ];

    programs.direnv = {
      enable = true;
      package = pkgs.direnv.overrideAttrs (_: {
        doCheck = false;
      });
      enableNushellIntegration = true;
      silent = true;
      nix-direnv.enable = true;
    };
  };
}
