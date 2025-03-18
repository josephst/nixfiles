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
}
