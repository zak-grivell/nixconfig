{
  flake.modules.nixos.desktop = {pkgs, ...}: {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    programs.hyprland.enable = true;
    programs.thunar.enable = true;
    services.gvfs.enable = true;
    console.keyMap = "uk";
    hardware.bluetooth.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;

    hardware.graphics = {
      enable = true;
      # Add multilib support alongside native x86-64 Mesa for Steam and Proton.
      enable32Bit = true;
    };
    programs.steam.enable = true;
    programs.gamemode.enable = true;

    # Keep the file server and remote sessions reachable while the desktop is idle.
    systemd.sleep.settings.Sleep = {
      AllowSuspend = false;
      AllowHibernation = false;
      AllowSuspendThenHibernate = false;
      AllowHybridSleep = false;
    };

    # SSH clients may forward TERM=xterm-ghostty.
    environment.systemPackages = [pkgs.ghostty.terminfo];
  };

  flake.homeModules.linux = {pkgs, ...}: {
    # Home Manager removed Wayprompt, but Stylix still enables its theme by default.
    stylix.targets.wayprompt.enable = false;

    programs.ghostty = {
      enable = true;
      settings.font-family = "JetBrainsMono Nerd Font";
    };

    services.hyprpolkitagent.enable = true;
    services.mako.enable = true;
    programs.rofi.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "lua";
      extraConfig = builtins.readFile ../../hosts/zakpc/hyprland.lua;
    };
  };
}
