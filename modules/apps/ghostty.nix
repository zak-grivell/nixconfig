{
  flake.homeModules.default = { pkgs, ... }:{
    # home.packages = with pkgs; [
    #   ghostty-bin
    # ];

    programs.ghostty = {
      enable = true;

      package = pkgs.ghostty-bin;

      installVimSyntax = true;

      settings = {
        theme = "dark:Catppuccin Frappe,light:Catppuccin Latte";
        window-padding-color="background";
        resize-overlay="never";
        font-family = "JetBrainsMono Nerd Font";
      };
    };
  };
}
