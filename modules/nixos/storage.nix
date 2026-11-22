{
  flake.modules.nixos.storage = {config, lib, pkgs, ...}: let
    home = config.users.users.zakgrivell.home;
    resticICloud = pkgs.writeShellScriptBin "restic-icloud-home" ''
      export RESTIC_REPOSITORY=rclone:icloud:Backups/zakpc-home
      export RESTIC_PASSWORD_FILE=${lib.escapeShellArg "${home}/.config/restic/icloud-home-password"}
      export RCLONE_CONFIG=${lib.escapeShellArg "${home}/.config/rclone/rclone.conf"}
      export PATH=${lib.makeBinPath [pkgs.rclone]}:$PATH
      exec ${pkgs.restic}/bin/restic "$@"
    '';
  in {
    environment.systemPackages = [pkgs.rclone resticICloud];

    systemd.services.icloud-home-backup = {
      description = "Back up the zakpc home directory to iCloud Drive";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "zakgrivell";
        UMask = "0077";
      };
      script = ''
        exec ${resticICloud}/bin/restic-icloud-home backup --one-file-system \
          --exclude=/nix/store \
          --exclude=${lib.escapeShellArg "${home}/.cache"} \
          --exclude=${lib.escapeShellArg "${home}/.local/share/Trash"} \
          --exclude=${lib.escapeShellArg "${home}/.gvfs"} \
          --exclude=${lib.escapeShellArg "${home}/.config/rclone"} \
          --exclude=${lib.escapeShellArg "${home}/.config/restic/icloud-home-password"} \
          ${lib.escapeShellArg home}
      '';
    };

    systemd.timers.icloud-home-backup = {
      description = "Run the iCloud home backup daily";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };

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
          path = config.users.users.zakgrivell.home;
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
