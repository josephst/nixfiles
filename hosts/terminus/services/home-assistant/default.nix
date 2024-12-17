{ config, lib, ... }:
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
      wemo = {
        discovery = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.home-assistant.enable [
    8989 # wemo
  ];

  services.caddy.virtualHosts."home.${domain}" = lib.mkIf config.services.home-assistant.enable {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
    useACMEHost = domain;
  };
}