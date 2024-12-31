{ config, lib, pkgs, ... }:
let
  inherit (config.networking) domain;
  customComponents = import ../../../../../pkgs/homeassistant-customcomponents;
in
{
  imports = [
    ./zwave.nix
    ./zigbee.nix
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      "default_config"

      "cast"
      "esphome"
      "google_translate"
      "homekit_controller"
      "homekit"
      "met"
      "plex"
      "sonos"
      "zwave_js"
      "mqtt"
    ];
    config = {
      # store these outside of configuration.yaml so that they can be edited
      # via web interface
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "automation desc" = [
        {
          alias = "Backup Home Assistant every night at 3 AM";
          trigger = {
            platform = "time";
            at = "03:00:00";
          };
          action = {
            alias = "Create backup now";
            service = "backup.create";
          };
        }
      ];
      "scene desc" = [ ];

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
      sonos = { };
    };

    customComponents = [
      (pkgs.callPackage customComponents.smartrent { })
    ];
  };

  networking.firewall.allowedTCPPorts = lib.mkIf config.services.home-assistant.enable [
    1400 # sonos
    8989 # wemo
    21063 # homekit bridge
    21064 # homekit bridge
  ];

  systemd.tmpfiles.rules = lib.mkIf config.services.home-assistant.enable [
    "f  ${config.services.home-assistant.configDir}/automations.yaml  - hass  hass"
    "f  ${config.services.home-assistant.configDir}/scenes.yaml       - hass  hass"
  ];

  services.caddy.virtualHosts."home.${domain}" = lib.mkIf config.services.home-assistant.enable {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
    useACMEHost = domain;
  };

  services.restic.backups.system-backup.paths = [
    "/var/lib/hass"
  ];
}
