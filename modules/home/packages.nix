{ pkgs, lib, config, ... }:
{
  # Nix packages to install to $HOME
  fonts.fontconfig.enable = true;

  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    helix
    pokeget-rs
    fastfetch
    uv
    rustup

    omnix

    ripgrep # Better `grep`
    fd
    sd
    tree
    gnumake

    # Nix dev
    cachix
    nil # Nix language server
    nix-info
    nixpkgs-fmt

    nixd
    # On ubuntu, we need this less for `man home-configuration.nix`'s pager to
    # work.
    less
    fish

    mkalias
  ];

  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ln -sfn $genProfilePath/home-path/Applications "$HOME/Applications/Home Manager Applications"
    '';
  };



  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    fzf.enable = true;
  };
}
