# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Keep optional application services stopped while the host is being reviewed.
  # Set this to true to restore the full service stack.
  fullServiceStackEnabled = false;
in
{
  imports = [
    ../common # nixos common
    ../common/roles/server.nix
    ../../common # nixos AND nix-darwin common

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
    ./disko-hdd-storage.nix # separate from other disko config to allow for adding drive w/o formatting existing drives
    ./networking.nix
    ./storage.nix

    # Core services kept online during review.
    ../common/mixins/tailscale.nix
    ./services/acme.nix
    ./services/caddy.nix
    ./services/homepage

    ./services/vscode-server.nix

    ../../../modules/nixos/backrest.nix
    ../../../modules/nixos/healthchecks.nix
    ../../../modules/nixos/rclone-sync.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.copyparty.nixosModules.default
  ]
  ++ lib.optionals fullServiceStackEnabled [
    # Optional application services.
    ./services/copyparty.nix
    ./services/home-assistant
    ./services/incus.nix
    ./services/ollama.nix
    ./services/paperless.nix
    ./services/servarr
    ./services/samba.nix
    ./services/restic-server.nix
    ./services/healthchecks.nix
    ./services/restic
    # ./services/unifi.nix # disabled since 12/3/2025 (Dream Router 7 now runs Unifi)
  ];

  # specialisations (note the spelling!)
  specialisation = {
    graphical.configuration = {
      imports = [
        ../common/mixins/gnome.nix
        ../common/mixins/xrdp.nix
      ];

      services.printing.enable = true;

      environment.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";

      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ config.hostSpec.username ];
      };
    };
  };

  systemd = {
    tmpfiles.rules = [ "d /storage - - - - -" ];

    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    settings.Manager = {
      KExecWatchdogSec = "1m";
      RebootWatchdogSec = "30s";
      RuntimeWatchdogSec = "15s";
    };

    sleep.settings.Sleep = {
      AllowHibernation = "no";
    };
  };

  boot = {
    plymouth.enable = false;
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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  system.stateVersion = "25.11";
  home-manager.users.${config.hostSpec.username}.home.stateVersion = "26.05";
  users.users.${config.hostSpec.username}.extraGroups = [
    "media"
    "render"
  ]
  ++ lib.optional fullServiceStackEnabled "incus-admin";

  # List services that you want to enable:
  services = {
    fwupd.enable = true;
    hardware.bolt.enable = true;
    smartd.enable = true;
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
    tailscale = {
      extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
