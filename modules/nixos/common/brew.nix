{
    homebrew.enable = true;
      homebrew.onActivation.cleanup = "zap";
      homebrew.masApps = {
      };
      homebrew.taps = [
        "nikitabobko/tap"
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
        "nikitabobko/tap/aerospace"
        "sf-symbols"
      ];
}
