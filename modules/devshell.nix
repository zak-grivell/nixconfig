{...}: {
  perSystem = {pkgs, ...}: {
    packages.default = pkgs.writeShellApplication {
      name = "deploy";
      runtimeInputs = [pkgs.git];
      runtimeEnv =
        if pkgs.stdenv.hostPlatform.isDarwin
        then {
          REBUILD_COMMAND = "darwin-rebuild";
          REBUILD_FLAKE = ".#zakbook";
        }
        else {
          REBUILD_COMMAND = "nixos-rebuild";
          REBUILD_FLAKE = "path:.#zakpc";
        };
      text = ''
        nix-collect-garbage -d
        nix run .#write-flake
        nix flake update
        git add .
        git commit --allow-empty --allow-empty-message -m ""
        git push
        sudo "$REBUILD_COMMAND" switch --flake "$REBUILD_FLAKE"
        nix-collect-garbage -d
      '';
    };
    devShells.default = pkgs.mkShell {
      name = "nix-config";

      packages = with pkgs; [
        nixd # Nix LSP with flake support
        alejandra # Opinionated Nix formatter
        statix # Linter / anti-pattern checker
        deadnix # Find unused nix bindings
        nix-tree # Browse flake dependency graph
      ];
    };
  };
}
