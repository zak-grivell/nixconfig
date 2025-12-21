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
    ];
  };
}
