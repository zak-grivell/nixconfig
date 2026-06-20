{
  flake.homeModules.default = {
    programs.zellij = {
      enable = true;

      settings = {
        theme = "catppuccin-frappe";
        default_layout = "extra-compact";
        pane_frames = false;
        default_shell = "nu";

        plugins = {
          # compact-bar = {
          #   location = "zellij:compact-bar";
          #   tooltip = "Ctrl b";
          # };
        };
        keybinds = {
          normal = {
            "bind \"Ctrl 1\"" = {
              GoToTab = 1;
            };
            "bind \"Ctrl 2\"" = {
              GoToTab = 2;
            };
            "bind \"Ctrl 3\"" = {
              GoToTab = 3;
            };
            "bind \"Ctrl 4\"" = {
              GoToTab = 4;
            };
            "bind \"Ctrl 5\"" = {
              GoToTab = 5;
            };
            "bind \"Ctrl 6\"" = {
              GoToTab = 6;
            };
            "bind \"Ctrl 7\"" = {
              GoToTab = 7;
            };
            "bind \"Ctrl 8\"" = {
              GoToTab = 8;
            };
            "bind \"Ctrl 9\"" = {
              GoToTab = 9;
            };
            "bind \"Ctrl t\"" = {
              NewTab = {};
            };
            "bind \"Ctrl n\"" = {
              GoToNextTab = {};
            };
            "bind \"Ctrl p\"" = {
              GoToPreviousTab = {};
            };
            "bind \"Ctrl w\"" = {
              LaunchOrFocusPlugin = {
                _args = ["zellij:session-manager"];
                floating = true;
                move_to_focused_tab = true;
              };
            };
          };
        };
      };

      layouts."extra-compact" = ''
        layout {
          default_tab_template {
            pane size=1 borderless=true {
              plugin location="zellij:compact-bar"
            }

            children
          }

          tab name="Tab #1" {
            pane borderless=true
          }
        }
      '';
    };
  };
}
