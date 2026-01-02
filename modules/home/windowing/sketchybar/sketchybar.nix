{ pkgs, ... }:

{
  home.packages = [ pkgs.sbarlua ];

  programs.sketchybar = {
    enable = true;

    sbarLuaPackage = pkgs.sbarlua;

    config = {
      source = ./config;
      recursive = true;
    };

    configType = "lua";
    extraLuaPackages = luaPkgs: with luaPkgs; [
      cjson
      (callPackage ./packages/luaposix.nix {})
    ];
  };
}
