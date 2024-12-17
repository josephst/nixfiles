{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  imports = [];

  services.home-assistant = {
    enable  = true;
    config = {
      frontend = {};
      default_config = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      wemo = {};
    };
  };

  services.caddy.virtualHosts."home.${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
    useACMEHost = domain;
  };
}