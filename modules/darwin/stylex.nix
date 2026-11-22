{inputs, ...}: {
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.darwin.system.imports = [
    inputs.stylix.darwinModules.stylix
    inputs.self.modules.generic.appearance
  ];

  flake.modules.generic.appearance = {
    pkgs,
    config,
    ...
  }: {
    stylix.enable = true;

    stylix.enableReleaseChecks = false;

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    stylix.fonts = {
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      emoji = config.stylix.fonts.monospace;
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "Jet Brains Mono";
      };
    };
  };
}
