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
    # ./services/blocky.nix
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

  myConfig = {
    tailscale.enable = true;
  };

  systemd = {
    tmpfiles.rules = [ "d /storage - - - - -" ];

    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 7.5s.
      # If the hardware watchdog does not get a signal for 15s,
      # it will forcefully reboot the system.
      runtimeTime = "15s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
      # Forcefully reboot when a host hangs after kexec.
      # This may be the case when the firmware does not support kexec.
      kexecTime = "1m";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

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
      # TODO: tailscale configures nftables to drop all packets in 100.x.y.z space that don't originate from tailscale
      # this causes some CG-NAT problems.
      # see https://github.com/tillycode/homelab/blob/8949686e58d36f1502db3a787af3aadb66b2799e/nixos/profiles/services/tailscale.nix#L48
      # and https://github.com/tailscale/tailscale/issues/925#issuecomment-1616354736
      # https://avilpage.com/2024/09/tailscale-cgnat-conflicts-resolution.html
      # alternatively, disabling IPV4 on tailscale should fix?
      # TODO: is there a way to run this on each switch? Will Tailscale reset it?
      # to modify CGNAT settings:
      # find the rule handle: `sudo nft -a list ruleset`
      # run `sudo nft replace rule filter ts-input handle 10 ip saddr 100.80.0.0/20 iifname != "tailscale0" counter drop` (replacing the handle ID as needed)
      # to replace the rule with a more limited rule
      # separately, tailscale is configured to only assign IP addresses in 100.80.0.0/20 range
      extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
