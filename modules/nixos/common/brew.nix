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
      "zed"
      "figma"
      "alt-tab"
      "kicad"
      "ltspice"
    ];
  };
}
