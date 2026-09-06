{
  flake.homeModules.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      opencode
      codex
      copilot-language-server
    ];

  };
    flake.modules.darwin.system = {
      homebrew.casks = [ "t3-code" ];
    };
}
