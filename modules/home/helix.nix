{ flake, system, ... }:

let
  inherit (flake) inputs;
in
{
  # home.packages = [ inputs.helix-cargo.packages.aarch64-darwin.default ];

  home.sessionVariables.HELIX_RUNTIME = "${inputs.helix-cargo.packages.aarch64-darwin.default}/lib/runtime";

  programs = {
    helix = {
      enable = true;
      package = inputs.helix-cargo.packages.aarch64-darwin.default;
      defaultEditor = true;
      settings = {
        theme = {
          light = "catppuccin_latte";
          dark = "catppuccin_frappe";
        };
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
    };
  };
}
