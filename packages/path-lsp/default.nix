{
  lib,
  vimUtils,
  writeText,
  helix-unwrapped,
  helixOverrides ? {},
}: let
  defaults = writeText "path-lsp-languages.json" (builtins.toJSON {
    defaults = builtins.fromTOML (builtins.readFile "${helix-unwrapped.src}/languages.toml");
    overrides = helixOverrides;
  });
in
  vimUtils.buildVimPlugin {
    pname = "path-lsp";
    version = "0.1.0";
    src = ./runtime;
    postInstall = ''
      cp ${defaults} $out/languages.json
    '';
    meta.description = "Flake-defined Helix language settings for PATH-based Neovim tools";
    meta.license = lib.licenses.mpl20;
  }
