{ lib, ... }:
{
  # programs.homebrew-apps = [ "ghostty " ];

  home.file.".config/ghostty/config".text = ''
    theme = dark:Catppuccin Frappe,light:Catppuccin Latte
    window-padding-color=background
    resize-overlay=never
    font-family = "JetBrainsMono Nerd Font"
    command=nu
  '';
}
