{
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };

  flake.modules.darwin.system = {config, ...}: {
    # modules = [ inputs.sops-nix.darwinModules.sops ];
    sops = {
      defaultSopsFile = ../secrets/github.yaml;
      age.keyFile = "/Users/zakgrivell/.config/sops/age/keys.txt";
      secrets.github_token = {};
    };

    # launchd.user.envVariables = {
    #   GITHUB_TOKEN = builtins.readFile /"config.sops.secrets.github_token.path";
    # };
  };

  flake.homeModules.default = {pkgs, config, ...}: {
    home.packages = with pkgs; [
      sops
    ];
    home.sessionVariables = {
      GITHUB_TOKEN = "$(cat /run/secrets/github_token)";
    };

    programs.nushell.environmentVariables= {
      GITHUB_TOKEN = "$(cat /run/secrets/github_token)";
    };
  };
}
