{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sketchybar

    (pkgs.lua54Packages.lua.withPackages (ps: [
      ps.cjson
      (ps.callPackage ./hidden/luaposix.nix {})
    ]))

  ];

  # home.sessionVariables = {
  #   # This is just an example; adjust the path as needed
  #   LUA_CPATH = "${pkgs.luaPackages.cjson}/lib/lua/${pkgs.lua54Packages.lua.luaversion}/?.so;;
  #                ${(pkgs.lua54Packages.callPackage ./hidden/luaposix.nix {})}/lib/lua/${pkgs.lua54Packages.lua.luaversion}/?.so;;";
  # };
}
