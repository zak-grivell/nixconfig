{ lib, ... }:
{
  # programs.homebrew-apps = [ "ghostty " ];

  home.file.".config/ghostty/config".text = lib.generators.toINI { } {
    main = {
      theme = "dark:catppuccin-frappe,light:catppuccin-latte";
      window-padding-color = "background";
      resize-overlay = "never";
      font-family = "\"JetBrainsMono Nerd Font\"";
    };
  };
}
