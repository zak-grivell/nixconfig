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
    nix run .#write-flake
    sudo darwin-rebuild switch --flake .
  '';
}

