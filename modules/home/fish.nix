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

  # # Use specialization to set theme flavor
  # specialisation = {
  #   dark.configuration.programs.fish.interactiveShellInit = ''
  #     fish_config theme choose "Catppuccin Frappe"
  #   '';

  #   light.configuration.programs.fish.interactiveShellInit = ''
  #     fish_config theme choose "Catppuccin Latte"
  #   '';
  # };

  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = false;
  #     format = "$directory\$character";
  #     character = {
  #       success_symbol = "[➜](bold green) ";
  #       error_symbol = "[✗](bold red) ";
  #     };
  #   };
  # };
}
