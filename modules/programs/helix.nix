{
  flake.homeModules.default = {
    programs = {
      helix = {
        enable = true;
        # package = inputs.helix-cargo.packages.aarch64-darwin.default;
        defaultEditor = true;

        settings = {
          theme = "catppuccin_frappe";
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
          };
        };
          languages = {
            language-server.rust-analyzer.config.check.command = "clippy";            
          };
      };
    };
  };
}
