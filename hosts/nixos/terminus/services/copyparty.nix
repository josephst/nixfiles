{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets."copyparty/joseph_password" = {
    file = ../secrets/copyparty/joseph_password.age;
    owner = "copyparty";
  };

  systemd.services.copyparty = {
    bindsTo = [ "storage.mount" ];
    after = [
      "storage.mount"
      "storage-media.mount"
    ];
  };

  services.copyparty = {
    enable = true;
    settings = {
      i = "127.0.0.1"; # force reverse proxy
      e2dsa = true; # enable file indexing and filesystem scanning
      e2ts = true; # enable multimedia indexing
      fk = 4; # "fk" enables filekeys (necessary for upget permission) (4 chars long)
      ansi = true; # color in log messages
      no-hash = "\.iso$"; # skips hashing file contents if path matches *.iso
      no-reload = true;
      hist = "/var/lib/copyparty"; # store .hist directories here
    };
    accounts = {
      joseph.passwordFile = config.age.secrets."copyparty/joseph_password".path;
    };
    volumes = {
      # copyparty automatically sets up systmed-tmpfiles for these paths
      "/" = {
        path = "/storage/copyparty";
        access = {
          r = "*";
          A = [ "joseph" ];
        };
      };
      "/media" = {
        path = "/storage/media";
        access = {
          r = "*";
          A = [ "joseph" ];
        };
      };
    };
  };

  users.users.copyparty.extraGroups = [ "media" ];

  services.caddy.virtualHosts."copyparty.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:3923
    '';
    useACMEHost = domain;
  };
}
