{ ... }: {
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    icon_theme = {
      light = "Catppuccin Latte";
      dark = "Catppuccin Frappé";
      mode = "system";
    };
    theme = {
      light = "Catppuccin Latte";
      dark = "Catppuccin Frappé";
      mode = "system";
    };
    vim_mode = true;
    ui_font_size = 16;
    buffer_font_size = 16;
    vim = {
      default_mode = "helix_normal";
    };
    toolbar = {
      agent_review = false;
      breadcrumbs = false;
      quick_actions = false;
      selections_menu = false;
    };
    auto_install_extensions = {
      catppuccin = true;
      catppuccin_icons = true;
      nix = true;
    };
    auto_save = "on_focus_change";
    tab_bar =  {
      show = true;
      show_nav_history_buttons = false;
      show_tab_bar_buttons = false;
    };
  };
}
