{
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin = {
      enable = true;

      settings = {
        flavour = "frappe";

        background = {
          light = "latte";
          dark = "frappe";
        };
      };
    };
    # plugins.lualine.enable = true;
  };
}
