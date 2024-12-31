{ config, ... }:
let
  inherit (config.networking) domain;
in {
  networking.firewall.allowedTCPPorts = [
    1883 # MQTT
    8083 # Zigbee2MQTT
  ];
  # ZIGBEE2MQTT
  age.secrets."hass/zigbee2mqtt.secret" = {
    file = ../../secrets/hass/zigbee2mqtt.secret.age;
    path = "/var/lib/zigbee2mqtt/secret.yaml";
    owner = "${config.systemd.services.zigbee2mqtt.serviceConfig.User}";
    group = "${config.systemd.services.zigbee2mqtt.serviceConfig.Group}";
  };
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false; # TODO: turn off after all devices joined
      mqtt = {
        server = "mqtt://localhost:1883";
        user = "zigbee2mqtt";
        password = "!secret password"; # expects a secret file at /var/lib/zigbee2mqtt/secret.yaml,
        # with contents `password: mqtt_password`
      };
      serial = {
        port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_a80856583b1fef1184a64ad0639e525b-if00-port0";
      };
      frontend.port = 8083;
    };
  };
  systemd.services."zigbee2mqtt.service".requires = [ "mosquitto.service" ];
  systemd.services."zigbee2mqtt.service".after = [ "mosquitto.service" ];

  services.caddy.virtualHosts."zigbee.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:${toString 8083}
    '';
    useACMEHost = domain;
  };


  # MOSQUITTO
  age.secrets."hass/zigbee2mqtt.pass" = {
    file = ../../secrets/hass/zigbee2mqtt.pass.age;
  };

  age.secrets."hass/hass.pass" = {
    file = ../../secrets/hass/hass.pass.age;
  };

  services.mosquitto = {
    enable = true;
    listeners = [{
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
    }];
  };
}
