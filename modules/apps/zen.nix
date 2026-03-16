{
  
  # flake-file.inputs = {
  #   zen-browser = {
  #     inputs = {
  #       home-manager.follows = "home-manager";
  #       nixpkgs.follows = "nixpkgs";
  #     };
  #     url = "github:0xc000022070/zen-browser-flake";
  #   };
  # };
  
  # flake.homeModules.default = { ... }:{
  #   programs.zen-browser.enable = true;
  # };
    flake.modules.darwin.system = {
      homebrew.casks = [ "zen" ];
    };
}
