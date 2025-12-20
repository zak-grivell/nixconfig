{ ... }:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

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
}
