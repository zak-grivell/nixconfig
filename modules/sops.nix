{inputs, ...}: {
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };

  flake.modules.darwin.system = {config, ...}: {
    imports = [
      inputs.sops-nix.darwinModules.sops
    ];
    
    
    # modules = [ inputs.sops-nix.darwinModules.sops ];
    sops = {
      defaultSopsFile = ../secrets/github.yaml;
      age.keyFile = "/Users/zakgrivell/.config/sops/age/keys.txt";
      secrets.github_token = {
        owner = "zakgrivell";
        mode = "0444"; # world readable
      };
    };

    # launchd.user.envVariables = {
    #   GITHUB_TOKEN = builtins.readFile /"config.sops.secrets.github_token.path";
    # };
  };

  flake.homeModules.default = {
    pkgs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      sops
    ];
    # home.sessionVariables = {
    #   GITHUB_TOKEN = "$(cat /run/secrets/github_token)";
    # };

    # programs.nushell.envFile.text = ''
    #   $env.GITHUB_TOKEN = (open /run/secrets/github_token | str trim)
    #   $env.SOPS_AGE_KEY_FILE = "/Users/zakgrivell/.config/sops/age/keys.txt";
    # '';
  };
}
