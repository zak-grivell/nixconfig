{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.default = pkgs.writeShellApplication {
        name = "deploy";
        runtimeInputs = [ pkgs.git ];
        text = ''
          git add .
          git commit --allow-empty --allow-empty-message -m ""
          git push
          nix run .#write-flake
          sudo darwin-rebuild switch --flake .
        '';
      };      devShells.default = pkgs.mkShell {
        
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
