{
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];


}
