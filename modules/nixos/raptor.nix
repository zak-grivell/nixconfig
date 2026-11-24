# Install as ~/config/modules/nixos/raptor.nix and regenerate the root flake.
{ inputs, ... }: {
  flake-file.inputs.raptor = {
    url = "path:/home/zakgrivell/projects/raptor";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.remote = {
    home-manager.users.zakgrivell = {
      imports = [ inputs.raptor.homeManagerModules.default ];
      services.raptor = {
        enable = true;
        desktop = true;
      };
    };
  };
}
