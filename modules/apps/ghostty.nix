{
  flake.darwin.system = {
    homebrew.casks = [ "ghostty" ];
  };

  flake.modules.homeManager.home = {
    home.file.".config/ghostty/config".text = ''
      theme = dark:Catppuccin Frappe,light:Catppuccin Latte
      window-padding-color=background
      resize-overlay=never
      font-family = "JetBrainsMono Nerd Font"
    '';
  };
}
