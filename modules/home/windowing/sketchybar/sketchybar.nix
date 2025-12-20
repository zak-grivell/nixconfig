{ ... }:
{
  programs.sketchybar = {
    enable = true;
    config = ./config;

    configType = "lua";
    extraLuaPackages = luaPkgs: with luaPkgs; [ cjson ];
  };
}
