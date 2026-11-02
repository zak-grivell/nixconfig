{
  flake.homeModules.default = {
    lib,
    ...
  }: {
    programs = {
      helix = {
        enable = true;
        defaultEditor = true;
        ignores = [".direnv/"];

        settings = {
          theme = lib.mkForce "catppuccin_frappe";
          editor = {
            cursor-shape.insert = "bar";
            inline-diagnostics.cursor-line = "hint";
            auto-save = {
              focus-lost = true;
              after-delay.enable = true;
            };
            soft-wrap.enable = true;
            line-number = "relative";
            end-of-line-diagnostics = "hint";
            insert-final-newline = false;
            bufferline = "always";
            file-picker = {
              hidden = false;
              git-ignore = true;
              git-global = true;
              git-exclude = true;
            };
          };
          keys.normal = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
            space.f = "file_picker_in_current_directory";
            space.F = "file_picker";
            X = ["extend_line_up" "extend_to_line_bounds"];
            A-x = "extend_to_line_bounds";
          };

          keys.select = {
            X = ["extend_line_up" "extend_to_line_bounds"];
            A-x = "extend_to_line_bounds";
          };
        };
        languages = {
          language-server.copilot = {
            command = "copilot-language-server";
            args = ["--stdio"];
          };
          language-server.rust-analyzer.config.check.command = "clippy";

          language = [
            {
              name = "nix";
              formatter = {
                command = "alejandra";
              };
            }
          ];
        };
      };
    };
  };
}
