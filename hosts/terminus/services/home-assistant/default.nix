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
      "met"
      "plex"
      "homekit_controller"
    ];
    config = {
      frontend = {};
      default_config = {};
      homekit = {};
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      wemo = {
        static = [
          "192.168.1.130"
          "192.168.1.131"
          "192.168.1.132"
        ];
      };
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