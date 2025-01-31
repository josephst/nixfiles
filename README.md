# Dotfiles w/ Nix and Home Manager

🔔 [Read a blog post about this repository](https://josephstahl.com/nix-for-macos-and-a-homelab-server/)

> This is my own dotfiles repo and is customized to my own preferences -
although I try to keep everything working properly, use any part of this repo
on your own system may break things! I'd recommend using this more for inspiration
than exact instructions.

## Mac
### Generate host keys

Run `sudo ssh-keygen -A` to generate default host keys (rsa, ecdsa, ed25519 according to documentation)
if they do not already exist.

### Install Nix

[Follow the Zero to Nix](https://zero-to-nix.com/start/install) guide to install Nix on MacOS.

### Install Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## NixOS

Installation of NixOS is done with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) to allow for unattended/ remote setups.

If a system is already defined in `flake.nix` (such as `terminus` or `vmware`), make sure the NixOS installer is running on that system.
Set a password for the `nixos` user on the installer (`passwd`), then get the IP address (`ip a`).
The rest of the install process is handled remotely, using SSH.

Ensure that disk setup is correctly configured with `disko`.
For examples, see [`disko.nix`](./hosts/nixos/vmware/disko.nix).
If re-installing to a system that already has a defined `hardware-configuration.nix`, run the following:

```
nix run github:nix-community/nixos-anywhere -- --flake .#vmware --target-host nixos@<IP ADDRESS> --build-on-remote
```

`--build-on-remote` is necessary in case of cross-architechture builds.
If there's not a `hardware-configuration.nix` file yet created, then run with the `--generate-hardware-config` flag:

```
nix run github:nix-community/nixos-anywhere -- --generate-hardware-config nixos-generate-config ./hosts/nixos/vmware/hardware-configuration.nix --flake .#vmware --target-host nixos@<IP ADDRESS> --build-on-remote --ssh-option "IdentitiesOnly=yes"
```

If using Agenix, add `--copy-host-keys` to the arguments above.
This copies the files at `/etc/ssh/ssh_host_*` to `/mnt/` so that they're available on the new system.
This takes care of the host keys, but user-specific keys (`/home/$USER/.ssh/*`) are also necessary to decrypt secrets if using the Agenix home-manager module.
As the new system is not yet installed, a new key must be generated on the system running `nixos-anywhere`
and copied over.
Use 1Password, or `ssh-keygen -t ed25519`, to generate the new key, then create a directory structure for it and copy the keys to this directory:

```bash
temp=$(mktemp -d) # or `set temp $(mktemp -d)` if using Fish shell
install -d -m755 "$temp/home/<user>/.ssh"

# get private key from 1password, or copy the generated key if using `ssh-keygen`
op read "op://Private/<hash>/private key" > "$temp/home/<user>/.ssh/id_ed25519"
op read "op://Private/<hash>/public key" > "$temp/home/<user>/.ssh/id_ed25519.pub"

# set correct permissions on keys
chmod 600 $temp/home/user/.ssh/id_ed25519*
```

Make sure to re-key secrets with the new key(s) prior to running `nixos-anywhere`.
Then, run `nixos-anywhere` with `--extra-files "$temp"` in addition to the above flags.

> Note that this will set ownership on these files to `root` when copied by `nixos-anywhere`.
> To work around this, include a `systemd.tmpfiles.rules` section in the user configuration to give ownership of the `~/.ssh` directory.
```nix
  systemd.tmpfiles.rules = [
    "d /home/joseph/.ssh 0700 joseph joseph -"
  ];
```

## NixOS: after setup

### Tailscale
`tailscale up --ssh` to log in to Tailscale.

Update dynamic DNS records with the tailscale IP to ensure that other devices on the Tailnet
can look up the Tailscale IP on public DNS servers

### Plex
First time, access at [192.168.1.xxx:32400/web](192.168.1.24:32400/web) to get it set up,
before trying to access via reverse proxy.

### Sabnabd
Edit `/var/lib/sabnzbd/sabnzbd.ini` to allow `sabnzbd.nixos.josephstahl.com` (under `host_whitelist`).
Also modify the listening port (try 8082, so that Unifi can listen on 8080)
