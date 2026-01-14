{ pkgs, ... }:
{
  programs.fish.shellAliases.zed = "zeditor";

  programs.zed-editor = {
    enable = true;

    extensions = [
      "html"
      "catppucin"
      "toml"
      "java"
      "catppuccin"
      "catppuccin_icons"
      "nix"
      "lua"
    ];

    extraPackages = [ pkgs.nixd ];

    userSettings = {
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
      features = {
        edit_prediction_provider = "zed";
      };

      helix_mode = true;
      ui_font_size = 14;
      buffer_font_size = 14;
      # toolbar = {
      #   agent_review = false;
      #   breadcrumbs = false;
      #   quick_actions = false;
      #   selections_menu = false;
      # };
      # tab_bar = {
      #   show = false;
      #   show_nav_history_buttons = false;
      #   show_tab_bar_buttons = false;
      # };
      diagnostics.inline.enabled = true;
      terminal.toolbar.breadcrumbs = false;

      autosave = "on_focus_change";

      debugger.dock = "right";
      # inline_code_actions = false;
      scrollbar.show = "never";
      terminal.dock = "right";

      languages = {
        Python = {
          language_servers = [
            "ty"
            "!basedpyright"
            "..."
          ];
        };

        Django = {
          formatter = [
            {
              external = {
                command = "uv";
                arguments = [
                  "run"
                  "djlint"
                  "-"
                  "--reformat"
                  "{buffer_path}"
                ];
              };
            }
          ];
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace && Editor";
        bindings = {
          ctrl-a = "workspace::ToggleLeftDock";
          ctrl-s = "workspace::ToggleBottomDock";
          ctrl-d = "workspace::ToggleRightDock";
          ctrl-o = "projects::OpenRecent";
        };
      }
      {
        context = "Editor";
        bindings = {
          alt-tab = "editor::AcceptEditPrediction";
        };
      }
      {
        "context" = "Editor && inline_completion";
        "bindings" = {
          "tab" = null;
        };
      }
    ];
  };
}
