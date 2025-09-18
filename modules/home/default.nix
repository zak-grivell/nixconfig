# A module that automatically imports everything else in the parent folder,
# except default.nix and anything inside the 'hidden' folder.
{
  imports = [
    ./spotlight/default.nix
    ./fish.nix
    ./gc.nix
    ./git.nix
    ./helix.nix
    ./me.nix
    ./nix.nix
    ./packages.nix
    ./zed.nix
    ./ghostty.nix
    #./aerospace.nix
    # zoom.nix
    # orcacad.nix
    # zen.nix
  ];
}
