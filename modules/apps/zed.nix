{
  flake.homeModules.disabled = {
    pkgs,
    lib,
    ...
  }: {
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

      userSettings = {
        icon_theme = {
          light = lib.mkForce "Catppuccin Latte";
          dark = lib.mkForce "Catppuccin Frappé";
          mode = lib.mkForce "system";
        };
        theme = lib.mkForce {
          light = lib.mkForce "Catppuccin Latte";
          dark = lib.mkForce "Catppuccin Frappé";
          mode = lib.mkForce "system";
        };
        features = {
          edit_prediction_provider = "zed";
        };

        which_key = {
          enabled = true;
          delay_ms = 100;
        };
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
          selections_menu = false;
          agent_review = false;
          code_actions = false;
        };

        helix_mode = true;

        diagnostics.inline.enabled = true;
        terminal.toolbar.breadcrumbs = false;

        autosave = "on_focus_change";

        debugger.dock = "right";

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
          context = "(VimControl && !menu)";
          bindings = {
            space = null;
          };
        }
      ];
    };
  };
}
