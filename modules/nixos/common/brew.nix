{
    homebrew.enable = true;
      homebrew.onActivation.cleanup = "uninstall";
      homebrew.masApps = {
      };
      homebrew.taps = [
        "FelixKratz/formulae"
      ];
      homebrew.brews = [
          # "FelixKratz/formulae/borders"
          # "FelixKratz/formulae/sketchybar"
      ];
      homebrew.casks = [
        "font-jetbrains-mono"
        "font-jetbrains-mono-nerd-font"
        "ghostty@tip"
        "sf-symbols"
        "zen"
      ];
}
