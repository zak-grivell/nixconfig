{
  flake.homeModules.default = {
    programs.yazi = {
      enable = true;

      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_reverse = true;
        };

        theme = {
          flavour = {
            light = "catppuccin-latte";
            dark = "catppuccin-frappe";
          };
        };
      };
    };
  };
}
