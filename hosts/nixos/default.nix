# This file holds config used on all NixOS hosts
{ inputs
, outputs
, config
, hostname
, isWorkstation
, isInstall
, pkgs
, platform
, lib
, modulesPath
, username
, stateVersion
, ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    (modulesPath + "/installer/scan/not-detected.nix")

    ./${hostname}
    ./_mixins/services
    ./_mixins/features
    ./_mixins/users
  ] ++ (builtins.attrValues outputs.nixosModules)
  ++ lib.optional isWorkstation ./_mixins/desktop;

  # always install these for all users on nixos systems
  environment = {
    systemPackages = [
      pkgs.deploy-rs.deploy-rs
      pkgs.htop
      pkgs.git
      pkgs.nix-output-monitor
      pkgs.wezterm.terminfo
      pkgs.ghostty.terminfo
    ] ++ lib.optionals isInstall [
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

    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  age = {
    secrets.ghToken = {
      file = ../../secrets/ghToken.age;
      mode = "0440";
    };
  };

  nix = {
    channel.enable = false;
    settings = {
      connect-timeout = lib.mkDefault 5;
      experimental-features = [ "nix-command" "flakes" ]
        ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";
      trusted-users = [ "@wheel" ];
      log-lines = lib.mkDefault 25;
      builders-use-substitutes = true;
      cores = 0;
    };
    extraOptions = ''
      !include ${config.age.secrets.ghToken.path}
    '';
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
    hostPlatform = lib.mkDefault "${platform}";
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
      flake = "/home/${username}/dev/nixfiles";
    };
    nix-index-database.comma.enable = isInstall;
    nix-ld = lib.mkIf isInstall {
      enable = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs hostname username stateVersion isWorkstation isInstall;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".backup-pre-hm";
  };

  services = lib.mkIf isInstall {
    fwupd.enable = true;
    hardware.bolt.enable = true;
    smartd.enable = true;
  };

  systemd = {
    extraConfig = "DefaultTimeoutStopSec=10s";
  };

  system = {
    inherit stateVersion;
    rebuild.enableNg = true; # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/release-notes/rl-2505.section.md
  };
}
