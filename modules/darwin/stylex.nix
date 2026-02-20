{
  flake-file.inputs = {
      stylix = {
        url = "github:nix-community/stylix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };
  
  flake.modules.darwin.system = { pkgs, ... }: {
    stylix.enable = false;

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

  };
}
