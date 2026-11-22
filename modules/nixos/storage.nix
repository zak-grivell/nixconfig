{
  flake.modules.nixos.storage = {config, ...}: {
    systemd.tmpfiles.rules = [
      "d /srv/nas 0700 zakgrivell users -"
      "d /srv/nas/Sync 0700 zakgrivell users -"
      "d /var/lib/syncthing 0700 zakgrivell users -"
    ];

    services.samba = {
      enable = true;
      openFirewall = false;
      nmbd.enable = false;
      settings = {
        global = {
          "server min protocol" = "SMB2_02";
          "disable netbios" = "yes";
          "smb ports" = "445";
          "map to guest" = "Never";
        };
        Files = {
          path = "/srv/nas";
          "read only" = "no";
          "valid users" = "zakgrivell";
          "guest ok" = "no";
          "create mask" = "0600";
          "directory mask" = "0700";
          "vfs objects" = "fruit streams_xattr";
          "fruit:metadata" = "stream";
        };
      };
    };

    services.syncthing = {
      enable = true;
      user = "zakgrivell";
      group = "users";
      dataDir = "/var/lib/syncthing";
      guiAddress = "127.0.0.1:8384";
      openDefaultPorts = false;
      overrideDevices = false;
      overrideFolders = false;
      settings.options = {
        listenAddresses = ["tcp://0.0.0.0:22000"];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [445 22000];
  };
}
