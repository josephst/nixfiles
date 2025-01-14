# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, inputs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-mdns

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./networking.nix
    ./disko.nix
    ./disko-hdd-storage.nix # separate from other disko config to allow for adding drive w/o formatting existing drives

    # Mixins
    ../optional/lanzaboote.nix
    ../optional/tailscale.nix

    # Services
    ./services/acme.nix
    ./services/blocky.nix
    ./services/caddy.nix
    ./services/hoarder.nix
    ./services/home-assistant
    ./services/netdata.nix
    ./services/paperless.nix
    ./services/unifi.nix
    ./services/vscode-server.nix
    ## LLM
    ./services/ollama.nix
    ./services/open-webui.nix
    ## Media & Sharing
    ./services/servarr
    ./services/samba.nix
    ## Backup
    ./services/restic-server.nix

    # Specific to this host
    ## Backups
    ./services/restic
    ## Dashboard
    ./services/homepage
  ];

  myconfig = {
    # TODO: remove these modules?
    gui.enable = false; # headless mode
    llm.enable = true;
  };

  systemd.tmpfiles.rules = [ "d /storage - - - - -" ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

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
    smartd.enable = true;
    tailscale.useRoutingFeatures = "both"; # enable IP forwarding for tailscale exit node
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

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
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
