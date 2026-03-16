{...}: {
  perSystem = {pkgs, ...}: {
    packages.default = pkgs.writeShellApplication {
      name = "deploy";
      runtimeInputs = [pkgs.git];
      text = ''
        nix run .#write-flake
        nix flake update
        git add .
        git commit --allow-empty --allow-empty-message -m ""
        git push
        sudo darwin-rebuild switch --flake .
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
