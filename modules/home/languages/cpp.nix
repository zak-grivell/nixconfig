{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clang
    pkg-config
    gnumake
    libiconv
  ];

  home.sessionVariables = {
    NIX_LDFLAGS = "-L${pkgs.zlib}/lib";
    NIX_CFLAGS_COMPILE = "-I${pkgs.zlib}/include";
  };

}
