{ config, ... }: {
  services.zwave-js = {
    enable = true;
    serialPort = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00";
    secretsConfigFile = config.age.secrets.zwave-js-keys.path;
  };
}