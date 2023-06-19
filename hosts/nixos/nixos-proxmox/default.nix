# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ## Common
    ../../common # shared between NixOS and Darwin
    ../shared.nix # shared between NixOS

    ## Services
    ./services/acme.nix
    ./services/caddy.nix
    ./services/coredns
    ./services/netdata
    ./services/tailscale.nix
    ## Media
    ./services/sabnzbd
    ./services/plex.nix
    ./services/prowlarr.nix
    ./services/radarr.nix
    ./services/sonarr.nix

    ## Backup
    ./services/rclone.nix
    # ./services/restic/healthchecks.nix
    ./services/restic/b2.nix
    ./services/restic/nas_maintenance.nix

    ## Dashboard
    ./services/homepage
    ./services/uptime-kuma.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos"; # Define your hostname.
    domain = "josephstahl.com";
    search = ["nixos.josephstahl.com" "taildbd4c.ts.net"];
    firewall.enable = false;
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  # systemd.services.NetworkManager-wait-online.enable = false; # causes problems with tailscale
  systemd.network.wait-online.anyInterface = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  age.secrets.smb = {
    file = ../../../secrets/smb.age;
    owner = "root";
    group = "root";
  };

  fileSystems."/mnt/nas" = {
    device = "//192.168.1.12/public"; # NAS IP
    fsType = "cifs";
    options = let
      # prevent hanging on network changes
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=600,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,gid=media,file_mode=0775,dir_mode=0775";
    in ["${automount_opts},credentials=${config.age.secrets.smb.path}"];
  };

  # List services that you want to enable:
  services = {
    qemuGuest.enable = true;
  };

  services.resolved.extraConfig = ''
    DNS=127.0.0.1
    DNSStubListener=no
  ''; # disable stub listener since coreDNS is already listening on :53
  services.resolved.dnssec = "false";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false; # true seems to break usage with flakes

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
