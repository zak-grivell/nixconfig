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
2. In Finder, use **Go → Connect to Server** with `smb://zakpc/Files`. In Files on iPhone or iPad, use **Connect to Server** and sign in as a registered user. On other computers, connect with an SMB client. The share opens the `zakgrivell` home directory.
3. For offline files on the Mac, install Syncthing there, then open the PC's Syncthing UI through an SSH tunnel:

   ```sh
   ssh -N -L 18384:127.0.0.1:8384 zakgrivell@zakpc
   ```

   Open `http://127.0.0.1:18384` on the Mac. Exchange device IDs and set the PC's device address on the Mac to `tcp://<PC-Tailscale-IPv4>:22000`. The Mac initiates the connection. Add a folder on the PC at `/srv/nas/Sync` or a subfolder, share it with the Mac, and accept it into a local folder on the Mac. Only folders you pair will occupy local space and sync edits in the background. Keep bulk files available through SMB. Syncthing propagates deletions, so keep a separate backup for important data.

## Chat with Hermes on Discord

Create a bot in the [Discord Developer Portal](https://discord.com/developers/applications), enable **Message Content Intent**, and install it on your server with the `bot` and `applications.commands` scopes. Give the bot access to a private text channel, with permission to send messages, attach files, and create and reply in threads. Enable Developer Mode in Discord and copy your numeric user ID. The gateway requires an explicit user allowlist and responds to mentions in server channels. [Hermes Discord setup](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/discord)

On zakpc, create the credential file as root and edit it locally. Keep the real tokens out of Git and Discord.

```sh
sudo install -d -m 0700 /etc/hermes-agent
sudo test -e /etc/hermes-agent/discord.env || sudo install -m 0600 /dev/null /etc/hermes-agent/discord.env
sudoedit /etc/hermes-agent/discord.env
```

```dotenv
DISCORD_BOT_TOKEN=your-bot-token
DISCORD_ALLOWED_USERS=your-numeric-user-id
```

Hermes uses ChatGPT/Codex OAuth. After switching to the configuration, run the login as the service account and complete the device-code prompt using your ChatGPT account. [Hermes provider configuration](https://hermes-agent.nousresearch.com/docs/integrations/providers)

```sh
cd ~/config
sudo nixos-rebuild switch --flake 'path:.#zakpc'
bash -c 'set -e; package=$(nix build --no-link --print-out-paths github:NousResearch/hermes-agent/v0.23.3#default); exec sudo -Hu hermes env HERMES_HOME=/var/lib/hermes/.hermes "$package/bin/hermes" auth add openai-codex --type oauth --no-browser'
sudo systemctl restart hermes-agent
sudo journalctl -u hermes-agent -n 50
```

Mention the bot in the private channel and ask it to list its workspace. Hermes runs as a dedicated account with a writable `/var/lib/hermes/workspace`, a headless Chromium browser, and shell tools for Git, Python, Node.js and media processing. Put files or projects you want it to work on in that workspace. Add credentials for integrations you want to use to the same environment file, then run `sudo systemctl restart hermes-agent`.

## Back up the home directory to iCloud Drive

After switching to the `zakpc` configuration, run the following commands as `zakgrivell`. In `rclone config`, create a remote named `icloud`, select `iclouddrive` with the Drive service, and complete Apple sign-in and two-factor authentication. rclone documents a 30-day trust token. Renew it with `rclone config reconnect icloud:` when authentication expires.

```sh
rclone config
chmod 600 ~/.config/rclone/rclone.conf
rclone lsd icloud:
install -d -m 700 ~/.config/restic
bash -c 'umask 077; set -o noclobber -o pipefail; od -An -N32 -tx1 /dev/urandom | tr -d "[:space:]" > "$HOME/.config/restic/icloud-home-password"'
restic-icloud-home init
sudo systemctl start icloud-home-backup.service
```

Keep a copy of the repository password in a password manager so you can restore after losing the PC. Generate the password and initialize the repository only on the first setup. When moving to a replacement machine, restore the original password file and reconnect rclone.

The timer runs at 03:00 local time and catches up on a missed run after boot. Restic deduplicates data across encrypted snapshots. Snapshots are kept until manually removed. The backup stays on the home filesystem and skips the Nix store, caches, Trash, GVFS and the backup credentials. Symlinks are saved as links.

Check the service log and restore a small sample to a temporary folder after the first backup.

```sh
journalctl -u icloud-home-backup.service -n 50
restic-icloud-home snapshots
bash -c 'restic-icloud-home restore latest --include /home/zakgrivell/config/flake.nix --target "$(mktemp -d)"'
```

## Use the desktop

Hyprland's monocle layout gives each normal window the full workspace. Floating dialogs stay usable. Zen is the default for web links and HTML files.

| Shortcut | Action |
| --- | --- |
| Alt+Tab or Alt+O | Next window on this workspace |
| Alt+Shift+Tab or Alt+I | Previous window on this workspace |
| Alt+X | Close the focused window |
| Alt+T / B / D / E | Open Ghostty / Zen / Thunar / Zed |
| Super+Space | Open the application launcher |
| Super+Tab | Open the window switcher across workspaces. Search or use Tab and the arrow keys, then press Enter to switch. |
| Alt+1–9 | Switch workspace |
| Alt+Shift+1–9 | Move the focused window to a workspace |
| Super+Shift+Q | Exit Hyprland |

The Linux profile installs the Homebrew counterparts through Nix, including Zoom, T3 Code, Proton VPN, Helium, Mole and the ChatGPT/Codex desktop app. Karere provides WhatsApp. Rofi replaces Tuna and mac-menu for launching apps, Ghostty with Rex or tmux covers the cmux workflow, and the iCloud Reminders launcher opens Apple's web app in place of the macOS `remindctl` CLI.

## Play games

Launch Steam and sign in. For Windows games, enable Steam Play under **Settings → Compatibility** and select a Proton version as needed. Keep the Steam library on a native Linux filesystem. Game compatibility and performance vary by title.
