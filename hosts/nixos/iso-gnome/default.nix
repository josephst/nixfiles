{
  pkgs,
  lib,
  config,
  ...
}:
{
  myConfig.gnome.enable = true;

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Add my keys to nixos user
  users.users.nixos.openssh.authorizedKeys.keys = lib.optionals (config.myConfig ? "keys") (
    builtins.attrValues config.myConfig.keys.users.joseph
  );

  # autoSuspend makes the machine automatically suspend after inactivity.
  # It's possible someone could/try to ssh'd into the machine and obviously
  # have issues because it's inactive.
  # See:
  # * https://github.com/NixOS/nixpkgs/pull/63790
  # * https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
  services.xserver.displayManager.gdm.autoSuspend = false;

  # override upstream
  environment.variables.QT_QPA_PLATFORM = lib.mkForce null;

  services.xserver.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'firefox.desktop', 'nixos-manual.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop', 'gparted.desktop', 'io.calamares.calamares.desktop' ]
    '';

    # Override GNOME defaults to disable GNOME tour and disable suspend
    extraGSettingsOverrides = ''
      [org.gnome.shell]
      welcome-dialog-last-shown-version='9999999999'
      [org.gnome.desktop.session]
      idle-delay=0
      [org.gnome.settings-daemon.plugins.power]
      sleep-inactive-ac-type='nothing'
      sleep-inactive-battery-type='nothing'
    '';

    extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];
  };
}
