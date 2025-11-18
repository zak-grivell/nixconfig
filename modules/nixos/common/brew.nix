{ ... }:
{

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    masApps = { };
    casks = [
      "ghostty"
      "zen"
      "orcaslicer"
      "ghdl"
      "figma"
      "alt-tab"
      "kicad"
      "ltspice"
      "godot"
      "visual-studio-code"
      "discord"
      "thebrowsercompany-dia"
      "ltspice"
    ];
  };
}
