{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (pkgs.platformio-core.overrideAttrs (old: {
      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pkgs.python313Packages.packaging ];
    }))
  ];
}
