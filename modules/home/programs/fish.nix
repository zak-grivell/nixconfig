{ pkgs, ... }:
let
  catppuccin-fish = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fish";
    rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
    hash = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
  };
in
{
  xdg.configFile."fish/themes/Catppuccin Latte.theme".source =
    "${catppuccin-fish}/themes/Catppuccin Latte.theme";
  xdg.configFile."fish/themes/Catppuccin Frappe.theme".source =
    "${catppuccin-fish}/themes/Catppuccin Frappe.theme";

  programs = {
    fish = {
      enable = true;

      interactiveShellInit = ''
        function fish_prompt
          set_color yellow
          echo -n (prompt_pwd)
          set_color normal
          echo -n ' > '
        end

        set fish_greeting # Disable greeting
        pokeget random --hide-name | fastfetch --file-raw -
      '';

      functions = {
        system-config = ''
          set config_dir ~/SystemConfig

          # Open config first
          hx $config_dir

          darwin_run
        '';

        system-update = ''
          set config_dir ~/SystemConfig

          nix flake update $config_dir

          darwin_run
        '';

        darwin-run = ''
          set config_dir ~/SystemConfig

          # Run nix — only continue if it succeeds
          if nix run $config_dir
            echo "nix run succeeded — committing changes…"

            if test -d $config_dir/.git
              cd $config_dir
              git add -A

              # Only commit if there are actual changes
              if not git diff --cached --quiet
                set msg "Update: "(date "+%Y-%m-%d %H:%M:%S")
                git commit -m "$msg"
                git push
              else
                echo "No changes to commit."
              end
            else
              echo "No git repo in $config_dir"
            end

          else
            echo "nix run failed — NOT committing or pushing."
          end

          echo "collecting garbage"
          nix-collect-garbage -d
        '';
      };

      plugins = [
        {
          name = "catppuccin/fish";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "fish";
            rev = "main";
            sha256 = "sha256-Oc0emnIUI4LV7QJLs4B2/FQtCFewRFVp7EDv8GawFsA=";
          };
        }
      ];
    };
  };
}
