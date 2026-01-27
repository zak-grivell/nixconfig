{ ... }: {
  flake-file.inputs.nix-homebrew.url = "github:zhaofengli/nix-homebrew";

  flake.modules.darwin.zakbook = { ... }: {
    nix-homebrew.user = "zakgrivell";
    nix-homebrew.enable = true;


    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
    };
  };
}
