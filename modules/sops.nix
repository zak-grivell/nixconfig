{
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };

  flake.modules.darwin.system = {config, ...}: {
    # modules = [ inputs.sops-nix.darwinModules.sops ];
    sops = {
      defaultSopsFile = ../secrets/github.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      secrets.github_token = {};
    };

    home.sessionVariables = {
      GITHUB_TOKEN = "$(cat ${config.sops.secrets.github_token.path})";
    };
  };

  flake.homeModules.default = {pkgs, ...}: {
    home.packages = with pkgs; [
      sops
    ];
  };
}
