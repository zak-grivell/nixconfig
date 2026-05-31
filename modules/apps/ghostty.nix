{
  flake.homeModules.default =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;

        package = pkgs.ghostty-bin;

        installVimSyntax = true;

        settings = {
          theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
          window-padding-color = "background";
          resize-overlay = "never";
          font-family = "JetBrainsMono Nerd Font";
          font-size = 20;
          macos-titlebar-style = "hidden";
          window-padding-x = 0;
          window-padding-y = 0;
          window-padding-balance = true;
        };
      };
    };
}
