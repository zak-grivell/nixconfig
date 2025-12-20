{ pkgs, ... }:
{
  home.packages = [ pkgs.sbarlua ];

  programs.sketchybar = {
    enable = true;
    config = {
      source = builtins.path {
        path = ./config;
        name = "sketchybar-config";
      };
      recursive = true;
    };

    sbarLuaPackage = pkgs.sbarlua;

    configType = "lua";
    extraLuaPackages = luaPkgs: with luaPkgs; [ cjson ];
  };
}
