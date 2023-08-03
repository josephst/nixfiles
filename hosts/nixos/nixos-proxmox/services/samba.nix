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
    enable = true; # TODO: enable once samba fully set up
    package = pkgs.samba4Full;
    securityType = "user";
    extraConfig = ''
      server string = nixos
      server role = standalone server
      disable netbios = yes
      browseable = yes
      map to guest = bad user
      guest account = nobody
      fruit:copyfile = yes
      server min protocol = SMB3_00
      max log size = 10000
      create mask = 0664
      directory mask = 2755
      force create mode = 0644
      force directory mode = 2755
    '';
    shares = {
      public = {
        path = "/mnt/exthdd/shares/public";
        "read only" = "no";
        "guest ok" = "yes";
      };
      joseph = {
        path = "/mnt/exthdd/shares/joseph";
        "read only" = "no";
        "valid users" = "joseph";
        "force user" = "joseph";
        "force group" = "users";
      };
    };
  };
}
