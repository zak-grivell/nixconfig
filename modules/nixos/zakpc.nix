{inputs, ...}: let
  hardwareConfig = ../../hosts/zakpc/hardware-configuration.nix;
in {
  flake-file.inputs.hermes-agent.url = "github:NousResearch/hermes-agent/v0.23.3";

  flake.modules.nixos.zakpc = {config, lib, pkgs, ...}: {
    imports = [
      inputs.hermes-agent.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.self.modules.generic.appearance
      inputs.self.modules.nixos.desktop
      inputs.self.modules.nixos.remote
      inputs.self.modules.nixos.storage
    ] ++ lib.optional (builtins.pathExists hardwareConfig) hardwareConfig;

    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true;
    networking.hostName = "zakpc";
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";

    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
    hardware.enableRedistributableFirmware = true;
    system.stateVersion = lib.mkDefault "26.05";
    nix.settings.experimental-features = ["nix-command" "flakes"];

    services.hermes-agent = {
      enable = true;
      extraPackages = with pkgs; [git ripgrep jq curl nodejs python3 uv ffmpeg];
      settings.browser.executable_path = lib.getExe pkgs.chromium;
      settings.model = {
        provider = "openai-codex";
        default = "gpt-6-sol";
      };
      settings.discord = {
        require_mention = true;
        history_backfill = false;
      };
    };
    systemd.services.hermes-agent = {
      unitConfig.ConditionPathExists = "/etc/hermes-agent/discord.env";
      serviceConfig = {
        ProtectHome = lib.mkForce true;
        EnvironmentFile = "/etc/hermes-agent/discord.env";
        ExecCondition = pkgs.writeShellScript "hermes-discord-config-check" ''
          if [[ -z ''${DISCORD_BOT_TOKEN:-} || ! ''${DISCORD_ALLOWED_USERS:-} =~ ^[0-9]+(,[0-9]+)*$ ]]; then
            echo 'Set DISCORD_BOT_TOKEN and numeric DISCORD_ALLOWED_USERS in /etc/hermes-agent/discord.env.' >&2
            exit 1
          fi
        '';
      };
    };

    services.sunshine.enable = true;
    systemd.user.services.sunshine.unitConfig.ConditionUser = "zakgrivell";
    networking.firewall.interfaces.eno1.allowedUDPPorts = [41641];
    networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
      allowedTCPPorts = [47984 47989 48010];
      allowedUDPPorts = [47998 47999 48000 48002 48010];
    };

    programs.fish.enable = true;
    users.users.zakgrivell = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.fish;
      linger = true;
    };

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
        isDarwin = false;
      };
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.zakgrivell.imports = [
        inputs.self.homeModules.default
        inputs.self.homeModules.linux
      ];
      users.zakgrivell.services.rex.tailscale.enable = true;
    };
  };
}
