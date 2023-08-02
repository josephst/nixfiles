{
  lib,
  pkgs,
  ...
}: {
  services.samba-wsdd.enable = true;
  services.samba.openFirewall = true;
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];

  # For a user to be authenticated on the samba server,
  # you must add their password using smbpasswd -a <user> as root.
  services.samba = {
    enable = false; # TODO: enable once samba fully set up
    securityType = "user";
    extraConfig = ''
      browseable = yes
      map to guest = bad user
      guest account = nobody
      fruit:copyfile = yes
      server min protocol = SMB3_00
    '';
    shares = {
      public = {
        path = "/mnt/exthdd";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
}
