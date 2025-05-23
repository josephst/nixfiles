# modules/nixos/myConfig/default.nix
{
  inputs,
  outputs,
  config,
  lib,
  pkgs,
  ...
}:
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
    boot.loader.timeout = lib.mkDefault 3;

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    boot.tmp.useTmpfs = lib.mkDefault true;
    zramSwap.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/New_York";

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
        openFirewall = lib.mkDefault true;
        settings = {
          PasswordAuthentication = lib.mkDefault false;
          PermitRootLogin = "prohibit-password";

          # Automatically remove stale sockets
          StreamLocalBindUnlink = "yes";
          # Allow forwarding ports to everywhere
          GatewayPorts = "clientspecified";
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
      localBinInPath = true; # add ~/.local/bin to $PATH
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

        # shells
        pkgs.bashInteractive
        pkgs.fish
        pkgs.nushell
        pkgs.zsh
      ];
      shells = [
        pkgs.bashInteractive
        pkgs.fish
        pkgs.nushell
        pkgs.zsh
      ];
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
      ssh = {
        knownHosts = {
          "github.com".hostNames = [ "github.com" ];
          "github.com".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

          "gitlab.com".hostNames = [ "gitlab.com" ];
          "gitlab.com".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

          "git.sr.ht".hostNames = [ "git.sr.ht" ];
          "git.sr.ht".publicKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        };
      };
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
