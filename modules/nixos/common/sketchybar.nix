{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.lua54Packages.lua.withPackages (ps: [
      ps.cjson
      (ps.callPackage ./hidden/luaposix.nix {})
    ]))
    pkgs.sketchybar
  ];

  services.sketchybar = {
    enable = true;
  };
}
