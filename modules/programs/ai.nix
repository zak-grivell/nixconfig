{ inputs, ... }:
{
  flake-file.inputs.codex-menubar.url = "github:zak-grivell/codex-menubar";

  flake.homeModules.default = { lib, pkgs, ... }: {
    home.packages = with pkgs; [
      opencode
      copilot-language-server
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      inputs.codex-menubar.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  };
    flake.modules.darwin.system = {
      homebrew.casks = [ "t3-code" "codex" "protonvpn" ];
    };
}
