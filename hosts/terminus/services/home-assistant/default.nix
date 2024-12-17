{ config, lib, ... }:
let
  inherit (config.networking) domain;
in
{
  imports = [
    ./zwave.nix
  ];

  services.home-assistant = {
    enable  = true;
    openFirewall = true;

    extraComponents = [
      "cast"
      "esphome"
      "google_translate"
      "homekit_controller"
      "met"
      "plex"
    ];
    config = {
      # store these outside of configuration.yaml so that they can be edited
      # via web interface
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

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
          "192.168.1.133"
          "192.168.1.134"
        ];
      };
      sonos = {};
      zwave_js = {};
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.home-assistant.enable [
    1400 # sonos
    8989 # wemo
  ];

  systemd.services.home-assistant.preStart = ''
    touch ${config.services.home-assistant.configDir}/{automations,scenes}.yaml
  '';

  services.caddy.virtualHosts."home.${domain}" = lib.mkIf config.services.home-assistant.enable {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
    useACMEHost = domain;
  };
}