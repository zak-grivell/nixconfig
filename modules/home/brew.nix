
{
  config,
  pkgs,
  lib,
  ...
}:

let
  taps = [
  ];

  brews = [
  ];

  casks = [
    "ghostty"
    "zen"
    "ultimaker-cura"
    "hammerspoon"
  ];
in
with lib;
{
  home.sessionPath = [ "/opt/homebrew/bin" ];

  home.file.".Brewfile" = {
    text =
      (concatMapStrings (
        tap:
        ''tap "''
        + tap
        + ''
          "
        ''

      ) taps)
      + (concatMapStrings (
        brew:
        ''brew "''
        + brew
        + ''
          "
        ''

      ) brews)
      + (concatMapStrings (
        cask:
        ''cask "''
        + cask
        + ''
          "
        ''

      ) casks);
    onChange = ''
      /nix/var/nix/profiles/system/sw/bin/brew bundle install --cleanup --no-upgrade --force --global --zap
    '';
  };
}
