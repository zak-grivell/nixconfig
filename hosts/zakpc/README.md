# zakpc

The BOSGAME P3 Lite profile uses x86-64 Linux, AMD firmware and native 64-bit Mesa graphics. It also installs 32-bit Mesa libraries for Steam and Proton games that need them. It shares the Mac's Home Manager settings for Fish, Git, Neovim, Zed, Yazi, and the Catppuccin Frappé theme. Hyprland, Zen and Ghostty provide the Linux desktop. The `zakbook` target still uses nix-darwin.

## Set up the PC

1. From the installed NixOS system, copy the generated hardware configuration into this checkout. Review the root, EFI and any data mounts against the actual PC. The host defaults to systemd-boot for UEFI. For an existing install, carry over its original `system.stateVersion`, bootloader overrides, and any required mount or encryption settings. An existing account can keep its password.

   ```sh
   cp /etc/nixos/hardware-configuration.nix hosts/zakpc/
   sudo nixos-rebuild build --flake 'path:.#zakpc'
   sudo nixos-rebuild switch --flake 'path:.#zakpc'
   ```

   Run these from the repo root on the PC. `path:.` includes local files before they are tracked by Git. For a fresh installation from live media, use the hardware configuration generated under `/mnt/etc/nixos` and run `nixos-install --root /mnt --flake 'path:.#zakpc'` after mounting the intended filesystems.

2. On the local console, set the new account's password with `sudo passwd zakgrivell` if needed. Sign in as that user and add your clients' **public** SSH keys to `~/.ssh/authorized_keys` with directory mode `0700` and file mode `0600`.

3. Enrol the PC with `sudo tailscale up`. Connect each client to your tailnet. Use the PC's full MagicDNS name or Tailscale IP if the short name `zakpc` does not resolve. Tailnet access rules should grant your devices TCP 22 for SSH, 445 for SMB and 22000 for Syncthing as needed.

## Develop from another device

From Ghostty on the Mac or an SSH app on iPad, phone or another computer, run `ssh -t zakgrivell@zakpc tmux new-session -A -s dev`. Keep working copies on the PC, for example in `~/code`. Run `codex login --device-auth` on the PC to authenticate Codex, then launch `codex` from a project. Disconnect and run the same SSH command to reattach.

Rex Preview runs as your personal systemd user service at boot. It stays up while you are logged out. From a Rex client, add `ssh://zakgrivell@zakpc` as a remote host. Verify it with `ssh zakgrivell@zakpc rex version` and `ssh zakgrivell@zakpc rex server status`. A reboot or Rex service restart ends live terminal processes. The PC disables system sleep so sessions and file services remain reachable while it is powered on.

## Browse and sync files

1. On the PC, run `sudo smbpasswd -a zakgrivell` to set the share password.
2. In Finder, use **Go → Connect to Server** with `smb://zakpc/Files`. In Files on iPhone or iPad, use **Connect to Server** and sign in as a registered user. On other computers, connect with an SMB client. The share stores files under `/srv/nas` on the system disk by default.
3. For offline files on the Mac, install Syncthing there, then open the PC's Syncthing UI through an SSH tunnel:

   ```sh
   ssh -N -L 18384:127.0.0.1:8384 zakgrivell@zakpc
   ```

   Open `http://127.0.0.1:18384` on the Mac. Exchange device IDs and set the PC's device address on the Mac to `tcp://<PC-Tailscale-IPv4>:22000`. The Mac initiates the connection. Add a folder on the PC at `/srv/nas/Sync` or a subfolder, share it with the Mac, and accept it into a local folder on the Mac. Only folders you pair will occupy local space and sync edits in the background. Keep bulk files available through SMB. Syncthing propagates deletions, so keep a separate backup for important data.

## Use the desktop

Hyprland's monocle layout gives each normal window the full workspace. Floating dialogs stay usable. Zen is the default for web links and HTML files.

| Shortcut | Action |
| --- | --- |
| Alt+Tab or Alt+O | Next window on this workspace |
| Alt+Shift+Tab or Alt+I | Previous window on this workspace |
| Alt+X | Close the focused window |
| Alt+T / B / D / E | Open Ghostty / Zen / Thunar / Zed |
| Super+Space | Open the application launcher |
| Alt+1–9 | Switch workspace |
| Alt+Shift+1–9 | Move the focused window to a workspace |
| Super+Shift+Q | Exit Hyprland |

The Linux profile installs the Homebrew counterparts through Nix, including Zoom, T3 Code, Proton VPN, Helium, Mole and the ChatGPT/Codex desktop app. Karere provides WhatsApp. Rofi replaces Tuna and mac-menu for launching apps, Ghostty with Rex or tmux covers the cmux workflow, and the iCloud Reminders launcher opens Apple's web app in place of the macOS `remindctl` CLI.

## Play games

Launch Steam and sign in. For Windows games, enable Steam Play under **Settings → Compatibility** and select a Proton version as needed. Keep the Steam library on a native Linux filesystem. Game compatibility and performance vary by title.
