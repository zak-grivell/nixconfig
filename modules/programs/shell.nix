{...}: {
  flake.modules.darwin.system = {pkgs, ...}: {
    programs.fish.enable = true;

    environment.shells = [
      pkgs.fish
      pkgs.zsh
      pkgs.xonsh
    ];

    users.users.zakgrivell.shell = pkgs.fish;
  };

  flake.homeModules.default = {pkgs, ...}: {
    home.packages = [pkgs.pokeget-rs pkgs.fastfetch pkgs.xonsh];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      STM32CubeMX_PATH = "/Applications/STMicroelectronics/STM32CubeMX.app/Contents/Resources";
      STM32_PRG_PATH = "/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/Resources/bin";
    };

    programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };

    stylix.targets.starship.enable = false;

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        palette = "catppuccin_frappe";
        palettes.catppuccin_frappe = {
          rosewater = "#f2d5cf";
          flamingo = "#eebebe";
          pink = "#f4b8e4";
          mauve = "#ca9ee6";
          red = "#e78284";
          maroon = "#ea999c";
          peach = "#ef9f76";
          yellow = "#e5c890";
          green = "#a6d189";
          teal = "#81c8be";
          sky = "#99d1db";
          sapphire = "#85c1dc";
          blue = "#8caaee";
          lavender = "#babbf1";
          text = "#c6d0f5";
          subtext1 = "#b5bfe2";
          subtext0 = "#a5adce";
          overlay2 = "#949cbb";
          overlay1 = "#838ba7";
          overlay0 = "#737994";
          surface2 = "#626880";
          surface1 = "#51576d";
          surface0 = "#414559";
          base = "#303446";
          mantle = "#292c3c";
          crust = "#232634";
          purple = "#ca9ee6";
          cyan = "#99d1db";
          white = "#c6d0f5";
          black = "#232634";
        };
        directory = {
          style = "bold lavender";
          truncation_length = 4;
        };
        git_branch.style = "bold mauve";
        git_status.style = "bold peach";
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold mauve)";
        };
        cmd_duration.style = "bold yellow";
        nix_shell.style = "bold sapphire";
        direnv = {
          disabled = false;
          style = "bold peach";
        };
      };
    };

    programs.fish = {
      enable = true;

      shellInit = ''
        fish_add_path --path --prepend "$HOME/Library/Application Support/carapace/bin"
        fish_add_path --path --append "$HOME/.nix-profile/bin" /opt/homebrew/bin
      '';

      interactiveShellInit = ''
        set -g fish_greeting
        pokeget random --hide-name | fastfetch --file-raw -
      '';

      shellAliases = {
        gcm = "git commit -m";
        ga = "git add .";
        gs = "git status";
        gp = "git push";
      };
    };
  };
}
