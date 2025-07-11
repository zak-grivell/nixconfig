# /Users/zakgrivell/nixconfig/modules/nixos/common/pkgs/default.nix
{ ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      aerospace = import ./aerospace.nix {
        inherit (prev) fetchzip gitUpdater installShellFiles lib stdenv versionCheckHook;
      };
    })
  ];
}
