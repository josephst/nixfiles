{ hostname
, desktop
, lib
, pkgs
, ...
}:
let
  installOn = [
    "terminus"
  ];
in
lib.mkIf (lib.elem "${hostname}" installOn && desktop != null) {
  assertions = [
    {
      assertion = desktop == "gnome";
      message = "RDP is only configured on GNOME desktop.";
    }
  ];

  environment.systemPackages = [
    pkgs.gnome-remote-desktop
  ];

  # services.gnome.gnome-remote-desktop.enable = true; # enabled by default if gnome is enabled

  systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];
  systemd.services."gnome-remote-desktop-configuration".wantedBy = [ "graphical.target" ];

  networking.firewall.allowedTCPPorts = [
    3389
  ];
  networking.firewall.allowedUDPPorts = [
    3389
  ];

  # systemd.services."gnome-remote-desktop" = {
  #   # a translation of upstream systemd service
  #   enable = true;
  #   description = "GNOME Remote Desktop";

  #   serviceConfig = {
  #     Type = "dbus";
  #     BusName = "org.gnome.RemoteDesktop";
  #     Restart = "on-failure";
  #     User = "gnome-remote-desktop";
  #     ExecStart="${pkgs.gnome-remote-desktop}/libexec/gnome-remote-desktop-daemon --system";
  #   };

  #   preStart = let
  #     sslCert = "~/.local/share/gnome-remote-desktop";
  #   in ''
  #     if [ ! -s ${sslCert}/tls.crt -o ! -s ${sslCert}/tls.key ]; then
  #       mkdir -p ${sslCert} || true
  #       ${lib.getExe pkgs.openssl} req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj /C=US/ST=NONE/L=NONE/O=GNOME/CN=gnome.org -out ${sslCert}/tls.crt -keyout ${sslCert}/tls.key
  #       chown root:gnome-remote-desktop ${sslCert}/tls.crt ${sslCert}/tls.key
  #       chmod 440 ${sslCert}/tls.crt ${sslCert}/tls.key
  #     fi
  #   '';

  #   wantedBy = [ "graphical.target" ];
  # };

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
