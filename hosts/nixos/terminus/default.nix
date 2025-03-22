# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs
, lib
, inputs
, ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
    ./disko-hdd-storage.nix # separate from other disko config to allow for adding drive w/o formatting existing drives
    ./networking.nix

    # Services
    ./services/home-assistant
    ./services/acme.nix
    ./services/blocky.nix
    ./services/caddy.nix
    ./services/netdata.nix
    ./services/paperless.nix
    ./services/unifi.nix
    ./services/vscode-server.nix
    ## LLM
    ./services/ollama.nix
    ## Media & Sharing
    ./services/servarr
    ./services/samba.nix
    ## Backup
    ./services/restic-server.nix

    ## Backups
    ./services/restic
    ## Dashboard
    ./services/homepage

    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  systemd.tmpfiles.rules = [ "d /storage - - - - -" ];

  boot = {
    plymouth.enable = false;
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    loader = {
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = lib.mkForce false;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];

  # List services that you want to enable:
  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [
        "/"
        "/storage"
      ];
    };
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ${lib.getExe pkgs.ethtool} -K eth0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
