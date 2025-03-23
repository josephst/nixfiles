{ inputs, outputs, config, lib, pkgs, stateVersion, platform, ... }:

let
  cfg = config.myConfig;
  substituters = { };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    ./gaming.nix
    ./gnome.nix
    ./networking.nix
    ./user.nix
    ./tailscale.nix
  ];

  options.myConfig = with lib; {
    nix.substituters = mkOption {
      type = types.listOf types.str;
      # TODO: populate with well-known substituters
      default = [ ];
    };
  };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    # Use systemd-boot to boot EFI machines
    boot.loader.systemd-boot.configurationLimit = lib.mkOverride 1337 10;
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.timeout = 3;

    boot.tmp.useTmpfs = lib.mkDefault true;
    zramSwap.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/New_York";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      hostPlatform = platform; # set in flake.nix for each system
      config.allowUnfree = true;
    };
    nix = {
      package = pkgs.nix;
      channel.enable = false;
      extraOptions = lib.optionalString (config.age.secrets ? "ghToken") ''
        !include ${config.age.secrets.ghToken.path}
      '';
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      gc = {
        options = lib.mkDefault "--delete-older-than 14d";
      };
      settings = {
        auto-optimise-store = lib.mkDefault true;
        substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
        experimental-features = [ "nix-command" "flakes" ]
          ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";
        trusted-users = [ "@wheel" ];
        log-lines = lib.mkDefault 25;
        builders-use-substitutes = true;
        cores = 0;
      };
    };

    services = {
      openssh = {
        enable = lib.mkDefault true;
        settings = {
          PasswordAuthentication = lib.mkDefault false;
          PermitRootLogin = lib.mkDefault "prohibit-password";
          # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
          KexAlgorithms = [
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
            "sntrup761x25519-sha512@openssh.com"
          ];
        };
      };
      fwupd.enable = true;
      hardware.bolt.enable = true;
      smartd.enable = true;
    };

    environment = {
      systemPackages = [
        pkgs.agenix
        pkgs.deploy-rs.deploy-rs
        pkgs.dnsutils
        pkgs.ghostty.terminfo
        pkgs.git
        pkgs.micro
        pkgs.htop
        pkgs.nix-output-monitor
        pkgs.wezterm.terminfo
        inputs.isd.packages.${pkgs.system}.default # interactive systemd
        pkgs.agenix
        pkgs.nvd
        pkgs.rsync

        # hardware
        pkgs.nvme-cli
        pkgs.lshw
        pkgs.usbutils
        pkgs.pciutils
        pkgs.smartmontools
      ];
      shells = [ pkgs.fish ];
      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };
    };

    age = {
      secrets.ghToken = {
        file = ../../../secrets/ghToken.age;
        mode = "0440";
      };
    };

    programs = {
      _1password.enable = true;
      command-not-found.enable = false;
      fish = {
        enable = true;
        useBabelfish = true;
        shellAliases = {
          nano = "micro";
        };
      };
      nh = {
        clean = {
          enable = true;
          extraArgs = "--keep-since 14d --keep 10";
        };
        enable = true;
      };
      nix-index-database.comma.enable = true;
      nix-ld.enable = true;
    };

    systemd = {
      extraConfig = "DefaultTimeoutStopSec=10s";
    };

    system = {
      inherit stateVersion;
      rebuild.enableNg = true; # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/release-notes/rl-2505.section.md
    };
  };
}
