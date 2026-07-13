{
  pkgs,
  ...
}:
{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session"; # gnome wayland session
    openFirewall = true;
  };
  services.gnome.gnome-remote-desktop.enable = true; # needs gnome-remote-desktop backend to work!!
}
