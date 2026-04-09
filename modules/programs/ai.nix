{
  flake.homeModules.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      opencode      
      copilot-language-server
    ];
  };
}
