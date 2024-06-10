{
  config,
  lib,
  pkgs,
  ...
}:
{
  age.secrets.smbpasswd = {
    file = ../secrets/smbpasswd.age;
  };

  users.groups.media = { };
  # create "samba-guest:media" user for accessing shares
  users.users."samba-guest" = {
    isSystemUser = true; # not a normal user account
    createHome = false;
    description = "Guest user for accessing Samba shares";
    group = "users";
    extraGroups = [ "media" ];
    shell = "/bin/nologin";
    uid = 3000; # keep same UID between reinstalls
  };

  # assign password to samba-guest
  # The smbpasswd is generated via:
  # pdbedit -a -u <username>
  # pdbedit -L -w > /tmp/smbpasswd
  # https://www.samba.org/samba/docs/current/man-html/pdbedit.8.html
  #
  # TODO: convert to systemd pre-start unitfile?
  system.activationScripts.sambaUserSetup = {
    text = ''
      ${lib.getBin pkgs.samba}/bin/pdbedit \
        -i smbpasswd:${config.age.secrets.smbpasswd.path} \
        -e tdbsam:/var/lib/samba/private/passdb.tdb
    '';
  };

  # tmpfiles to create shares
  systemd.tmpfiles.settings = {
    "10-samba-shares" = {
      "/storage/media" = {
        d = {
          user = "samba-guest";
          group = "media";
          mode = "0775";
        };
      };
      "/storage/homes/public" = {
        d = {
          user = "samba-guest";
          group = "users";
          mode = "0775";
        };
      };
    };
  };

  # For a user to be authenticated on the samba server,
  # you must add their password using smbpasswd -a <user> as root.
  services.samba = {
    enable = true;
    package = pkgs.samba.override { enableMDNS = true; };
    securityType = "user";
    invalidUsers = [ "root" ];
    openFirewall = true;
    extraConfig = ''
      # basic config
      server string = nixos
      server role = standalone server
      disable netbios = yes
      load printers = no
      server min protocol = SMB3_00

      # performance tweaks
      use sendfile = yes
      min receivefile size = 16384

      # Mac-friendly options
      fruit:copyfile = yes
      vfs objects = fruit streams_xattr
      fruit:metadata = stream
      fruit:aapl = yes
      fruit:encoding = native
      fruit:model = MacPro
      fruit:posix_rename = yes
      fruit:veto_appledouble = no
      fruit:nfs_aces = no
      fruit:wipe_intentionally_left_blank_rfork = yes
      fruit:delete_empty_adfiles = yes

      browseable = yes
      map to guest = bad user
      guest account = nobody

      logging = systemd
      max log size = 10000

      create mask = 0664
      force create mode = 0664
      directory mask = 0775
      force directory mode = 0775
    '';
    shares = {
      public = {
        path = "/storage/homes/public";
        "public" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "only guest" = "yes";
        "writable" = "yes";
        "force user" = "samba-guest";
      };

      media = {
        path = "/storage/media";
        "force user" = "samba-guest";
      };
    };
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
