{
  hostname,
  desktop,
  lib,
  pkgs,
  ...
}:
let
  installOn = [
    "terminus"
  ];
in
lib.mkIf (lib.elem "${hostname}" installOn) {
  assertions = [
    { assertion = desktop == "gnome";
      message = "RDP is only configured on GNOME desktop."; }
  ];

  environment.systemPackages = [
    pkgs.gnome-remote-desktop
  ];

  # services.gnome.gnome-remote-desktop.enable = true; # enabled by default if gnome is enabled

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
