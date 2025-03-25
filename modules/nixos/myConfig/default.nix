# modules/nixos/myConfig/default.nix
{ inputs, outputs, config, lib, pkgs, ... }:

{
  imports = [
    ../../common/myConfig
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

  config = {
    myConfig.stateVersion = lib.mkDefault "24.11"; # NixOS stateVersion

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
      hostPlatform = config.myConfig.platform; # set in flake.nix for each system
      config.allowUnfree = true;
    };

    nix = {
      settings = {
        trusted-users = [ "@wheel" ];
      };
    };

    security = {
      # use ssh keys instead of password
      pam.sshAgentAuth.enable = true;
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
    };

    environment = {
      systemPackages = [
        # nixos-specific packages
        inputs.isd.packages.${pkgs.system}.default # interactive systemd
        pkgs.dnsutils
        pkgs.ghostty.terminfo
        pkgs.htop
        pkgs.wezterm.terminfo
        pkgs.rsync

        # hardware
        pkgs.nvme-cli
        pkgs.lshw
        pkgs.usbutils
        pkgs.pciutils
        pkgs.smartmontools
      ];
      shells = [ pkgs.fish ];
    };

    programs = {
      _1password.enable = true;
      nh = {
        clean = {
          enable = true;
          extraArgs = "--keep-since 14d --keep 10";
        };
        enable = true;
      };
      nix-ld.enable = true;
    };

    systemd = {
      extraConfig = "DefaultTimeoutStopSec=10s";
    };

    system = {
      inherit (config.myConfig) stateVersion;
      rebuild.enableNg = true; # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/release-notes/rl-2505.section.md
    };
  };
}
