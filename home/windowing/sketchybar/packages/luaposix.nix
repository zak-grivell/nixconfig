{ buildLuarocksPackage, fetchurl, fetchzip, luaAtLeast, luaOlder, ... }:
buildLuarocksPackage {
  pname = "luaposix";
  version = "36.3-1";
  knownRockspec = (fetchurl {
    url    = "mirror://luarocks/luaposix-36.3-1.rockspec";
    sha256 = "0jwah6b1bxzck29zxbg479zm1sqmg7vafh7rrkfpibdbwnq01yzb";
  }).outPath;
  src = fetchzip {
    url    = "http://github.com/luaposix/luaposix/archive/v36.3.zip";
    sha256 = "0k05mpscsqx1yd5vy126brzc35xk55nck0g7m91vrbvvq3bcg824";
  };

  disabled = luaOlder "5.1" || luaAtLeast "5.5";

  meta = {
    homepage = "http://github.com/luaposix/luaposix/";
    description = "Lua bindings for POSIX";
    license.fullName = "MIT/X11";
  };
}
