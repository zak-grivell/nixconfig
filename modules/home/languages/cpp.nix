{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clang
    pkg-config
    gnumake
    libiconv

    zlib
  ];

  home.sessionVariables = {
    LDFLAGS = "-L${pkgs.zlib}/lib";
    CFLAGS_COMPILE = "-I${pkgs.zlib}/include";
    CPPFLAGS = "-I${pkgs.zlib}/include";
  };
}
