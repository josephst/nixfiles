{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.networking) domain;
in
{
  imports = [
    ./zwave.nix
    ./zigbee.nix
  ];

  age.secrets."hass/secrets.yaml" = {
    file = ../../secrets/hass/secrets.yaml.age;
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    group = "hass";
    mode = "660";
  };

  services.home-assistant = {
    enable = true;

    extraComponents = [
      "androidtv_remote"
      "apple_tv"
      "cast"
      "esphome"
      "google_translate"
      "homekit_controller"
      "homekit"
      "isal"
      "met"
      "mqtt"
      "plex"
      "sonos"
      "wemo"
      "zha" # not used, but causes error if missing
      "zwave_js"
    ];
    config = {
      default_config = { };
      # store these outside of configuration.yaml so that they can be edited
      # via web interface
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";

      "automation nixos" = [
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
      "scene nixos" = [ ];

      homeassistant = {
        packages = "!include_dir_named ${./packages}";
        unit_system = "us_customary";
        time_zone = "America/New_York";
        temperature_unit = "F";
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
      };

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
      # wemo = {
      #   static = [
      #     "192.168.1.132" # living room lamp (now added via homekit device)
      #   ];
      # };
      sonos = { };
      recorder = {
        purge_keep_days = 30;
        db_url = "sqlite:///${config.services.home-assistant.configDir}/home-assistant_v2.db";
      };
      # history = { };
      rest_command = {
        healthchecks = {
          url = "!secret healthchecks";
        };
      };
    };

    customComponents = [
      pkgs.home-assistant-custom-components.smartrent
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
      reverse_proxy http://localhost:8123
    '';
    useACMEHost = domain;
  };

  services.caddy.virtualHosts."home.${config.networking.domain}.${config.hostSpec.tailnet}" =
    lib.mkIf config.services.home-assistant.enable
      {
        extraConfig = ''
          reverse_proxy http://localhost:8123
        '';
      };

  services.restic.backups.system-backup.paths = [
    "/var/lib/hass"
  ];
}
