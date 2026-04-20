{inputs,... }: {
  flake-file.inputs = {
    nixvim.url = "github:nix-community/nixvim";
  };

  flake.homeModules.default = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];

    programs.nixvim = {
      enable = true;

      colorschemes.catppuccin.enable = true;
      plugins.lualine.enable = true;
   plugins.lspconfig.enable = true;plugins.lspconfig.autoLoad = true;
    };
  };
}
