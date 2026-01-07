{ flake, ... }:

final: prev: {
  aerospace = flake.packages.${final.system}.aerospace;
}
