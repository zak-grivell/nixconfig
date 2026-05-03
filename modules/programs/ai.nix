{
  flake.homeModules.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      opencode
      codex
      copilot-language-server
    ];
  };
}
