{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Nix packages to install to $HOME
  fonts.fontconfig.enable = true;

  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
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

    libiconv

    zlib

    beam28Packages.elixir_1_19
    (pkgs.beam28Packages.elixir-ls.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [
      pkgs.hex
      pkgs.beam28Packages.elixir_1_19
    ];

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      pkgs.rebar3
    ];

    doCheck = false;
  }))    surfer

    pkg-config
     
    nixd
    # On ubuntu, we need this less for `man home-configuration.nix`'s pager to
    # work.
    less
    fish

    clang

    mkalias

    manix

    ollama

    jdk25

    yazi

    platformio

    # vhdl
    vhdl-ls

    # pyton
    ty
    ruff

    nerd-fonts.jetbrains-mono
  ];


home.sessionVariables = {
  NIX_LDFLAGS = "-L${pkgs.zlib}/lib";
  NIX_CFLAGS_COMPILE = "-I${pkgs.zlib}/include";
};

  services.ollama = {
    enable = true;
    port = 11434; # optional, default is 11434
  };

  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    fzf.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    zellij.enable = true;
  };
}
