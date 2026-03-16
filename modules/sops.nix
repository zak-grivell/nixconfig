{
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };


    flake.modules.darwin.system = {inputs, ...}: {
      # modules = [ inputs.sops-nix.darwinModules.sops ];
    };
}
