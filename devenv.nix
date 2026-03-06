{ pkgs,... }: {
  languages.nix.enable = true;

  packages = with pkgs; [
    omnix
    cachix
    nix-info
    nixpkgs-fmt
    manix
  ];

  scripts.run.exec = ''
    git add .
    git commit --allow-empty --allow-empty-message -m ""
    git push
    nix run .#write-flake
    sudo darwin-rebuild switch --flake .
  '';
}

