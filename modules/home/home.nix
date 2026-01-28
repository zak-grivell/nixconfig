let
  host = "aarch64-darwin";
in {
  flake.homeModules.default = { pkgs, ...}: {
    home.username = "zakgrivell";
    home.homeDirectory = /Users/zakgrivell;
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
    programs.zsh.enable = true;
    home.packages = with pkgs; [
      ripgrep
      fd
    ];
  };
}
