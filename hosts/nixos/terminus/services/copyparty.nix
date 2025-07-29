{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets."copyparty/joseph_password" = {
    file = ../secrets/copyparty/joseph_password.age;
    owner = "copyparty";
  };

  services.copyparty = {
    enable = true;
    accounts = {
      joseph.passwordFile = config.age.secrets."copyparty/joseph_password".path;
    };
    volumes = {
      # copyparty automatically sets up tmpfiles
      "/" = {
        path = "/storage/copyparty";
        access = {
          r = "*";
          rw = [ "joseph" ];
        };
        flags = {
          # "fk" enables filekeys (necessary for upget permission) (4 chars long)
          fk = 4;
          # scan for new files every 60sec
          scan = 60;
          # volflag "e2d" enables the uploads database
          e2d = true;
          # "d2t" disables multimedia parsers (in case the uploads are malicious)
          d2t = true;
          # skips hashing file contents if path matches *.iso
          nohash = "\.iso$";
        };
      };
    };
  };

  services.caddy.virtualHosts."copyparty.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:3923
    '';
    useACMEHost = domain;
  };
}
