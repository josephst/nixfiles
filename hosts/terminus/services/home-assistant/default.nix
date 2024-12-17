{ config, lib, ... }:
let
  inherit (config.networking) domain;
in
{
  imports = [];

  services.home-assistant = {
    enable  = true;
    openFirewall = true;
    configWritable = true; # will be over-written each time the service starts, but helps w/ rapid iteration
    extraComponents = [
      "esphome"
      "google_translate"
    ];
    config = {
      frontend = {};
      default_config = {};
      homekit = {};
      homekit_controller = {};
      met = {};
      plex = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      wemo = {};
      sonos = {};
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.home-assistant.enable [
    1400 # sonos
    8989 # wemo
  ];

  services.caddy.virtualHosts."home.${domain}" = lib.mkIf config.services.home-assistant.enable {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
    useACMEHost = domain;
  };
}