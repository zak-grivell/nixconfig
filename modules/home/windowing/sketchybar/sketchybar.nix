{ ... }:
{
  programs.sketchybar = {
    enable = true;
    config = {
      source = ./config;
      recursive = true;
    };
    configType = "lua";
    extraLuaPackages = luaPkgs: with luaPkgs; [ cjson ];
  };
}
