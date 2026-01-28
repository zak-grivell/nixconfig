{ ... }:
{
  flake.modules.homeManager.home = {
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
    };
  };
}
