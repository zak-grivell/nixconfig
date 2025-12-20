{ pkgs, ... }:
{
  home.packages = with pkgs; [
    beam28Packages.elixir_1_19
    (pkgs.beam28Packages.elixir-ls.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [
        pkgs.hex
        pkgs.beam28Packages.elixir_1_19
      ];

      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.rebar3
      ];

      doCheck = false;
    }))

    entr

  ];
}
