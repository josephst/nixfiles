{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.determinate.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    ./networking.nix
  ];

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    boot = {
      loader.systemd-boot = {
        enable = lib.mkDefault true;
        configurationLimit = lib.mkOverride 1337 10;
      };
      loader.timeout = lib.mkDefault 3;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      tmp.useTmpfs = lib.mkDefault true;
    };
    zramSwap.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/New_York";

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
        inputs.isd.packages.${pkgs.stdenv.hostPlatform.system}.default # interactive systemd
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
        enable = true;
      };
      nix-ld.enable = true;
    };

    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };

    system = {
      stateVersion = "25.11";
    };
  };
}
