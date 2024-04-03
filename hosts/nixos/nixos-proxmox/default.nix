# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
    ./disko-hdd-storage.nix # separate from other disko config to allow for adding drive w/o formatting existing drives

    # srvOS
    # ../mixins/cloud-init.nix
    ../mixins/nix-experimental.nix
    ../mixins/systemd-boot.nix
    ../mixins/server.nix
    ../mixins/terminfo.nix

    # Secrets
    ./secrets.nix

    ## Services
    ./services/acme.nix
    ./services/caddy.nix
    # ./services/coredns
    ./services/dnsmasq.nix
    ./services/netdata
    ./services/tailscale.nix
    ## Media
    ./services/sabnzbd
    ./services/plex.nix
    ./services/prowlarr.nix
    ./services/radarr.nix
    ./services/sonarr.nix

    ## Backup
    # ./services/rclone.nix
    # ./services/rsync.nix
    ./services/samba.nix
    # ./services/restic/healthchecks.nix
    ./services/restic/restic-user.nix
    # ./services/restic/b2.nix
    # ./services/restic/exthdd.nix
    # ./services/restic/nas_maintenance.nix

    ## Dashboard
    ./services/homepage
    # ./services/uptime-kuma.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Create the group for media stuff (plex, sabnzbd, etc)
  users.groups.media = { };

  networking = {
    hostName = "nixos"; # Define your hostname. (managed by cloud-init)
    hostId = "e2dfd738"; # head -c 8 /etc/machine-id
    domain = "josephstahl.com";
    # search = ["josephstahl.com" "taildbd4c.ts.net"];

    # networkmanager - disabled, use systemd-networkd instead
    networkmanager.enable = false; # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  fileSystems."/mnt/nas" = {
    device = "//192.168.1.12/public"; # NAS IP
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "gid=media"
      "file_mode=0775"
      "dir_mode=0775"
      "credentials=${config.age.secrets.smb.path}"
    ];
  };

  # fileSystems."/mnt/exthdd" = {
  #   device = "/dev/disk/by-uuid/d7f9520d-262f-4e80-8296-964ca82eeb77";
  #   fsType = "ext4";
  #   options = [
  #     "nofail"
  #     "x-systemd.device-timeout=5"
  #   ];
  # };

  # List services that you want to enable:
  services = {
    qemuGuest.enable = true;
    resolved.dnssec = "allow-downgrade";
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
