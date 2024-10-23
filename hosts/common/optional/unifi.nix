{config, pkgs, ...}:
let
  inherit (config.networking) domain;
in {
  services.unifi = {
    enable = true;
    openFirewall = true;

    unifiPackage = pkgs.unifi8;
    mongodbPackage = pkgs.mongodb-ce; # pre-built binary
  };

  services.caddy.virtualHosts."unifi.${domain}" = {
    extraConfig = ''
      reverse_proxy https://localhost:8443 {
        transport http {
          tls_insecure_skip_verify # we don't verify the controller https cert
        }
        header_up - Authorization  # sets header to be passed to the controller
      }
    '';
    useACMEHost = domain;
  };
}
