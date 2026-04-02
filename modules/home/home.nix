let
  host = "aarch64-darwin";
in {
  flake-file.inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  flake.homeModules.default = { pkgs, inputs, ...}: {
    home.username = "zakgrivell";
    # home.homeDirectory = /Users/zakgrivell;
    home.stateVersion = "26.05";
    # programs.home-manager.enable = true;
    # programs.zsh.enable = true;
  };
}
