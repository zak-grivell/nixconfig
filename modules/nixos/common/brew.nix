{ config, lib, ... }:

{

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    masApps = { };
    casks = [
      "ghostty"
      "zen"
      "orcaslicer"
    ];
  };
}
