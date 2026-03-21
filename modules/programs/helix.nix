{
  flake.homeModules.default = {lib, ...}: {
    programs = {
      helix = {
        enable = true;
        # package = inputs.helix-cargo.packages.aarch64-darwin.default;
        defaultEditor = true;

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
            bufferline = "always";
          };
          keys.normal = {
            esc = [
              "collapse_selection"
              "keep_primary_selection"
            ];
            space.f = "file_picker_in_current_directory";
            space.F = "file_picker";
          };
        };
        languages = {
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
