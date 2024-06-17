{
  pkgs,
  lib,
  config,
  options,
  ...
}:
{
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  age.identityPaths = [
    # key to use for new installs, prior to generation of hostKeys
    "/etc/agenixKey"
    "/etc/ssh/ssh_host_ed25519_key" # this is the default location, but orbstack doesn't have ssh enabled so we have to manually create key (ssh-keygen -A) and list it here
  ] ++ options.age.identityPaths.default;

  # Use systemd during boot as well on systems except:
  # - systems with raids as this currently require manual configuration (https://github.com/NixOS/nixpkgs/issues/210210)
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  # - For systemd in initrd we have now systemd-repart, but many images still set boot.growPartition
  boot.initrd.systemd.enable = lib.mkDefault (
    !(
      if lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11" then
        config.boot.swraid.enable
      else
        config.boot.initrd.services.swraid.enable
    )
    && !config.boot.isContainer
    && !config.boot.growPartition
  );
  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = lib.mkDefault true;

  environment = {
    # NixOS specific (shared with Darin = goes in ../../common/default.nix)
    systemPackages =
      [
        pkgs.cifs-utils
        pkgs.tailscale
        pkgs.wezterm.terminfo # this one does not need compilation
        # avoid compiling desktop stuff when doing cross nixos
      ]
      ++ lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
        pkgs.termite.terminfo
        # Too unstable
        # pkgs.kitty.terminfo
        pkgs.foot.terminfo
      ];
  };

  programs = {
    ssh = {
      startAgent = true;
    };
    nix-ld = {
      enable = true; # necessary for VSCode Server support
    };
  };

  services = {
    openssh.enable = lib.mkDefault true;
    resolved.enable = lib.mkDefault true; # mkDefault lets it be overridden
  };

  security.pam.sshAgentAuth.enable = true; # enable password-less sudo (using SSH keys)
  security.pam.services.sudo.sshAgentAuth = true;

  # NETWORKING
  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;
  # Keep dmesg/journalctl -k output readable by NOT logging
  # each refused connection on the open internet.
  networking.firewall.logRefusedConnections = lib.mkDefault false;
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

  # NIX
  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;

  # TODO: cargo culted.
  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;
  nix.settings.experimental-features = [
    # for container in builds support
    "auto-allocate-uids"
    "cgroups"
  ];
  nix.settings.auto-allocate-uids = true;

  # SSH
  services.openssh = {
    settings.X11Forwarding = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PasswordAuthentication = false;
    settings.UseDns = false;
    # unbind gnupg sockets if they exists
    settings.StreamLocalBindUnlink = true;

    # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
    settings.KexAlgorithms = [
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
      "sntrup761x25519-sha512@openssh.com"
    ];
    # Only allow system-level authorized_keys to avoid injections.
    # We currently don't enable this when git-based software that relies on this is enabled.
    # It would be nicer to make it more granular using `Match`.
    # However those match blocks cannot be put after other `extraConfig` lines
    # with the current sshd config module, which is however something the sshd
    # config parser mandates.
    authorizedKeysFiles = lib.mkIf (
      !config.services.gitea.enable
      && !config.services.gitlab.enable
      && !config.services.gitolite.enable
      && !config.services.gerrit.enable
      && !config.services.forgejo.enable
    ) (lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ]);
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
}
