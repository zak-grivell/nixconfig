{ ... }:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.modules.homeManager.zakbook = {
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
