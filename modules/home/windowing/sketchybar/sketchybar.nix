{ pkgs, ... }:

{
  home.packages = [ pkgs.sbarlua ];

  # xdg.configFile."sketchybar" = {
  #   source = ./config;
  #   recursive = true;
  # };

  programs.sketchybar = {
    enable = true;

    sbarLuaPackage = pkgs.sbarlua;

    config = {
      source = ./config;
      recursive = true;
    };

    configType = "lua";
    extraLuaPackages = luaPkgs: with luaPkgs; [ cjson ];
  };
}
