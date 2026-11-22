{inputs, ...}: {
  flake-file.inputs.rex = {
    url = "https://pkgs.superlogical.com/rex/nix/preview.tar.gz";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.remote = {config, ...}: {
    services.tailscale.enable = true;
    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [22];
  };

  flake.homeModules.linux = {pkgs, ...}: {
    imports = [inputs.rex.homeManagerModules.default];
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
    services.rex.enable = true;
    programs.tmux.enable = true;
    home.packages = [pkgs.codex];
  };
}
