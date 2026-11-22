{inputs, ...}: let
  hardwareConfig = ../../hosts/zakpc/hardware-configuration.nix;
in {
  flake.modules.nixos.zakpc = {lib, pkgs, ...}: {
    imports = [
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
    };
  };
}
