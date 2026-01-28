{
  flake.homeModules.default = { pkgs, ... }:
  {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          padding = {
            left = 4;
            right = 4;
            top = 4;
          };
        };
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "display"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "cursor"
          "terminal"
          "terminalfont"
          "cpu"
          "gpu"
          "memory"
          "localip"
          "battery"
          "poweradapter"
          "break"
          "colors"
        ];
      };
    };

    home.packages = with pkgs; [
      pokeget-rs
    ];
  };
}
