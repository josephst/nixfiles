# This file (and the global directory) holds config used on all hosts
{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  options,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    ../default.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./systemd-initrd.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  services = {
    resolved = {
      enable = lib.mkDefault true;
      dnsovertls = "opportunistic";
    };
  };

  hardware.enableRedistributableFirmware = true;

  age.identityPaths = [
    # key to use for new installs, prior to generation of hostKeys
    "/etc/agenixKey"
    "/etc/ssh/ssh_host_ed25519_key" # this is the default location, but orbstack doesn't have ssh enabled so we have to manually create key (ssh-keygen -A) and list it here
  ] ++ options.age.identityPaths.default;

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "--- diff to current-system"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        echo "---"
      fi
    '';
  };

  # always install these for all users on nixos systems
  environment = {
    variables = {
      # SHELL = "fish";
    };
    systemPackages =
      [
        # most are in ../common/default.nix
        pkgs.htop
        pkgs.nh

        # hardware
        pkgs.lshw
        pkgs.pciutils
        pkgs.smartmontools
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
        # avoid compiling desktop stuff when doing cross nixos
        pkgs.termite.terminfo
        # Too unstable
        # pkgs.kitty.terminfo
        pkgs.foot.terminfo
      ];
  };

  # SERIAL
  # default is something like vt220... however we want to get alt least some colors...
  systemd.services."serial-getty@".environment.TERM = "xterm-256color";

  # SUDO
  # Only allow members of the wheel group to execute sudo by setting the executable’s permissions accordingly. This prevents users that are not members of wheel from exploiting vulnerabilities in sudo such as CVE-2021-3156.
  security.sudo.execWheelOnly = true;
  # Don't lecture the user. Less mutable state.
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault false;
  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services.systemd-networkd.stopIfChanged = false;
  # Services that are only restarted might be not able to resolve when resolved is stopped before
  systemd.services.systemd-resolved.stopIfChanged = false;

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/release-notes/rl-2411.section.md
  systemd.enableStrictShellChecks = false; # TODO: broken because of linger-users script
}
