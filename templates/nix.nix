{ pkgs,... }: {
  language.nix.enable = true;

  packages = with pkgs; [
    omnix
    cachix
    nix-info
    nixpkgs-fmt
    manix
  ];
}
