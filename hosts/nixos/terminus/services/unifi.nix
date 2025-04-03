{ config, pkgs, ... }:
let
  inherit (config.networking) domain;
in
{
  services.unifi = {
    enable = true;
    openFirewall = true;

    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-ce; # pre-built binary
  };

  networking.firewall.allowedTCPPorts = [ 8443 ];

  services.caddy.virtualHosts."unifi.${domain}" = {
    extraConfig = ''
      reverse_proxy https://localhost:8443 {
        transport http {
          tls
          tls_insecure_skip_verify # we don't verify the controller https cert
        }
        header_up - Authorization  # sets header to be passed to the controller
      }
    '';
    useACMEHost = domain;
  };
}
