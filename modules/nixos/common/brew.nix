{ ... }:
{

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    masApps = { };
    casks = [
      "tabtab"
      "ghostty"
      "zen"
      "figma"
      "ltspice"
      "godot"
      "kicad"
      "ghdl"
      "orcaslicer"
      "font-sf-pro"
      "helium-browser"
      "whatsapp"
    ];
  };
}
