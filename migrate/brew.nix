{ ... }:
{

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    masApps = { };
    casks = [
      "tabtab"
      "ltspice"
      "orcaslicer"
      "helium-browser"
      "whatsapp"
      "utm"
    ];
  };
}
