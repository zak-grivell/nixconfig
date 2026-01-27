{ pkgs, ... }:
{
  # for editiing basic md files
  home.packages = with pkgs; [
    rumdl
    markdown-oxide
  ];

  programs = {
    helix = {
      enable = true;
      # package = inputs.helix-cargo.packages.aarch64-darwin.default;
      defaultEditor = true;

      settings = {
        theme = "catppuccin_frappe";
        #   light = "catppuccin_latte";
        #   dark = "catppuccin_frappe";
        # };
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
        language-server = {
          elixir-ls = {
            command = "${pkgs.elixir-ls}/bin/elixir-ls";
            environment = {
              ELIXIRLS_SKIP_HOST_ELIXIR = "1";
            };
          };
        };
      };
    };
  };
}
