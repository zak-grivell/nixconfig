{ ...} : {
  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        editor = {
          cursor-shape = {
          insert = "bar";
          };
          inline-diagnostics = {
            cursor-line = "hint";
          };
          auto-save = {
            focus-lost = true;
            after-delay.enable = true;
          };
          soft-wrap.enable = true;
          line-number="relative";
          end-of-line-diagnostics = "hint";
          bufferline = "always";
        };
          keys.normal = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
          };
      };
    };
  };

    specialisation = {
      light.configuration.programs.helix.settings.theme = "catppuccin_latte";
      dark.configuration.programs.helix.settings.theme = "catppuccin_frappe";
    };

}
