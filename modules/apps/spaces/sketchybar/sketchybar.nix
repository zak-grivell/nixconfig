{
  flake.homeModules.default = { pkgs, ... }:

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
      (pkgs.luaPackages.buildLuarocksPackage {
        pname = "luaposix";
        version = "36.3-1";
        knownRockspec = (pkgs.fetchurl {
          url    = "mirror://luarocks/luaposix-36.3-1.rockspec";
          sha256 = "0jwah6b1bxzck29zxbg479zm1sqmg7vafh7rrkfpibdbwnq01yzb";
        }).outPath;
        src = pkgs.fetchzip {
          url    = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
          sha256 = "0k05mpscsqx1yd5vy126brzc35xk55nck0g7m91vrbvvq3bcg824";
        };

        meta = {
          homepage = "http://github.com/luaposix/luaposix/";
          description = "Lua bindings for POSIX";
          license.fullName = "MIT/X11";
        };
      })
    ];
  };
};

}
