{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  # shared configuration that should be used for ALL NixOS installs

  ### taken from SrvOS (https://github.com/numtide/srvos/tree/main/nixos/common)
  imports = [
    ./secrets.nix
    ./security.nix
    ./mdmonitor-fix.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./serial.nix
    ./sudo.nix
    ./zfs.nix
  ];

  # Use systemd during boot as well on systems except:
  # - systems that require networking in early-boot
  # - systems with raids as this currently require manual configuration (https://github.com/NixOS/nixpkgs/issues/210210)
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = lib.mkDefault (
    !config.boot.initrd.network.enable
    && !(
      if lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11" then
        config.boot.swraid.enable
      else
        config.boot.initrd.services.swraid.enable
    )
    && !config.boot.isContainer
    && !config.boot.growPartition
  );

  # Allow sudo from the @wheel group
  security.sudo.enable = true;

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = lib.mkDefault true;

  # If the user is in @wheel they are trusted by default.
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # No mutable users by default
  users.mutableUsers = false;

  # Make sure firewall is enabled
  networking.firewall.enable = lib.mkDefault true;
  # Delegate the hostname setting to dhcp/cloud-init by default
  networking.hostName = lib.mkDefault "";

  ### END srvOS portion

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  environment = {
    # NixOS specific (shared with Darin = goes in ../../common/default.nix)
    systemPackages = with pkgs; [
      cifs-utils
      tailscale
    ];
  };

  programs = {
    nix-ld = {
      enable = true;
    };
    ssh = {
      startAgent = true;
    };
    fish = {
      # workaround for https://github.com/NixOS/nixpkgs/issues/173421
      useBabelfish = true;
    };
  };

  services = {
    resolved.enable = lib.mkDefault true; # mkDefault lets it be overridden
    openssh.enable = lib.mkDefault true;
  };

  security.pam.sshAgentAuth.enable = true; # enable password-less sudo (using SSH keys)
  security.pam.services.sudo.sshAgentAuth = true;
}
