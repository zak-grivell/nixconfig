{inputs, ...}: {
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.home-manager.follows = "home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.homeModules.linux = {
    imports = [inputs.zen-browser.homeModules.beta];
    stylix.targets.zen-browser.enable = false;
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };
  };

  flake.modules.darwin.system.homebrew.casks = ["zen" "helium-browser" "chatgpt"];
}
