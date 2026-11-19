{ inputs, ... }:
{
  flake-file.inputs.codex-menubar.url = "github:zak-grivell/codex-menubar";

  flake.homeModules.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      opencode
      copilot-language-server
      inputs.codex-menubar.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  };
    flake.modules.darwin.system = {
      homebrew.casks = [ "t3-code" "codex" "protonvpn" ];
    };
}
