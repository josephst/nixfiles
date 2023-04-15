# Dotfiles w/ Nix and Home Manager

🔔 [Read a blog post about this repository](https://josephstahl.com/nix-for-macos-and-a-homelab-server/)

> This is my own dotfiles repo and is customized to my own preferences - 
although I try to keep everything working properly, use any part of this repo
on your own system may break things! I'd recommend using this more for inspiration
than exact instructions. 

## Mac
### Install Nix

[Follow the Zero to Nix](https://zero-to-nix.com/start/install) guide to install Nix on MacOS.

### Install Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## NixOS

Download and boot the minimal ISO from (unstable version).

Run `sudo -i` to switch to root, then `mkpasswd` to set a root password.
This enables ssh login (get ip with `ip a`) to run the rest of the installer via ssh.

Complete partitioning [per the NixOS instructions](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-partitioning).

Once partitoning is complete and the system is mounted to `/mnt`,
we'll deviate from the installer and use `flake.nix` to install the system.

```shell
# install agenix to get secrets loaded
nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix
nix-channel --update

# Open up a shell to get git:
nix-shell -p git nixFlakes

# copy ssh keys over so that we can authenticate with github
# alternatively, may make new keys with ssh-keygen and copy them to github
# not necessary if cloning a public repo
mkdir ~/.ssh
vim ~/.ssh/id_ed25519 # enter private key that is used to authenticate with Github (stored in 1password)
chmod 600 ~/.ssh/id_ed25519

# add new keys for agenix
mkdir -p /mnt/etc/secrets/initrd
ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key
cat /mnt/etc/secrets/initrd/ssh_host_ed25519_key.pub # copy the public key
# re-encrypt with this new key, then pull the repo again to get newly encrypted files
cd /mnt/etc/nixos
git pull

# once shell loaded, clone the repo to /mnt/etc/nixos
git clone git@github.com:josephst/dotfiles4.git /mnt/etc/nixos
cd /mnt/etc/nixos

# update flake
nix --experimental-features 'flakes nix-command' flake update

# prepare for new hardware-configuration
rm /mnt/etc/nixos/hosts/nixos/nixos-proxmox/hardware-configuration.nix

# generate new config (ignore the generated configuration.nix)
nixos-generate-config --root /mnt
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/nixos/nixos-proxmos/
rm /mnt/etc/nixos/configuration.nix

# make sure we're in the right directory
cd /mnt/etc/nixos
git add --all # add the new hardware config
git commit -m "update hardware config" # commit it
git push # and push to github

# needs more space to build (at least 4GB)
mount -o remount,size=4G /run/user/0

# install
nixos-install --flake .#nixos -j 4
```

## NixOS: after setup

### Tailscale
`tailscale up --ssh` to log in to Tailscale.

Then, need to [update Google Domains with the Tailscale IP](https://domains.google.com).

### Plex
First time, access at [192.168.1.24:32400/web](192.168.1.24:32400/web) to get it set up, 
before trying to access via reverse proxy.

### Sabnabd
Edit `/var/lib/sabnzbd/sabnzbd.ini` to allow `sabnzbd.nixos.josephstahl.com` (under `host_whitelist`)
