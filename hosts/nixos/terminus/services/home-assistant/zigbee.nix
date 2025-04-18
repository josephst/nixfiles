{ config, pkgs, ... }:
let
  inherit (config.networking) domain;
in
{
  networking.firewall.allowedTCPPorts = [
    1883 # MQTT
  ];
  # ZIGBEE2MQTT
  age.secrets."hass/zigbee2mqtt.secret.yaml" = {
    # the file must end in .yaml
    file = ../../secrets/hass/zigbee2mqtt.secret.age;
    owner = "${config.systemd.services.zigbee2mqtt.serviceConfig.User}";
    group = "${config.systemd.services.zigbee2mqtt.serviceConfig.Group}";
  };
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.zigbee2mqtt_2;
    settings = {
      permit_join = false;
      mqtt = {
        # base_topic = "zigbee2mqtt"; # default
        # server = "mqtt://localhost"; # default
        user = "zigbee2mqtt";
        password = "!${config.age.secrets."hass/zigbee2mqtt.secret.yaml".path} password"; # expects a secret file at /var/lib/zigbee2mqtt/secret.yaml,
        # with contents `password: mqtt_password`
      };
      serial = {
        adapter = "ember"; # necessary for Sonoff Zigbee Dongle-E
        port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_a80856583b1fef1184a64ad0639e525b-if00-port0";
      };
      frontend = {
        port = 8083;
        url = "https://zigbee.${domain}";
      };
      advanced = {
        homeassistant_legacy_entity_attributes = false;
        homeassistant_legacy_triggers = false;
        legacy_api = false;
        legacy_availability_payload = false;
        network_key = "!${config.age.secrets."hass/zigbee2mqtt.secret.yaml".path} network_key";
      };
      device_options = {
        legacy = false;
      };
    };
  };
  systemd.services."zigbee2mqtt.service".requires = [ "mosquitto.service" ];
  systemd.services."zigbee2mqtt.service".after = [ "mosquitto.service" ];

  services.caddy.virtualHosts."zigbee.${domain}" = {
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString config.services.zigbee2mqtt.settings.frontend.port}
    '';
    useACMEHost = domain;
  };

  services.restic.backups.system-backup.paths = [
    "/var/lib/zigbee2mqtt/"
  ];

  # MOSQUITTO
  age.secrets."hass/zigbee2mqtt.pass" = {
    file = ../../secrets/hass/zigbee2mqtt.pass.age;
  };

  age.secrets."hass/hass.pass" = {
    file = ../../secrets/hass/hass.pass.age;
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        # address = "0.0.0.0"; # 0.0.0.0 is the default
        settings.allow_anonymous = true;
        omitPasswordAuth = false;
        acl = [ "topic readwrite #" ];

        users.hass = {
          acl = [
            "readwrite #"
          ];
          passwordFile = config.age.secrets."hass/hass.pass".path;
        };

        users."${config.services.zigbee2mqtt.settings.mqtt.user}" = {
          acl = [
            "readwrite #"
          ];
          passwordFile = config.age.secrets."hass/zigbee2mqtt.pass".path;
          # expects a secret file containing plaintext password
          # this is the same password referred to by services.zigbee2mqtt.settings.mqtt.password (just in a different format)
        };
      }
    ];
  };
}
