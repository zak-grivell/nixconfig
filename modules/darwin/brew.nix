{ inputs, ... }: {
  flake-file.inputs.nix-homebrew.ul = "github:zhaofengli/nix-homebrew";

  flake.modules.darwin.zakbook = { ... }: {
    nix-homebrew.user = "zakgrivell";
    nix-homebrew.enable = true;


    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
    };
  };
}
