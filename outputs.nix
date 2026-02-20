inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  systems = import inputs.systems;

  imports = [
      (inputs.import-tree ./modules)
      inputs.flake-parts.flakeModules.modules
      inputs.home-manager.flakeModules.home-manager
  ];
}
