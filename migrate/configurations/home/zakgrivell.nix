{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  me = {
    username = "zakgrivell";
    fullname = "Zak Grivell";
    email = "zak@grivell.uk";
  };

  home.stateVersion = "24.11";
}
