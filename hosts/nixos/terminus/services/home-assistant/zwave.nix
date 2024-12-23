{ config, ... }: {
  services.zwave-js = {
    enable = true;
    serialPort = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00";
    secretsConfigFile = config.age.secrets.zwave-js-keys.path;
  };

  age.secrets.zwave-js-keys = {
    file = ../../secrets/zwave-js-keys.json.age;
    # TODO: use systemd's LoadCredential so that this file doesn't need to be globally readable
    mode = "774"; # needs to be readable by user zwave-js, but this is created by systemd's DynamicUser
  };
  # virtualisation.oci-containers.containers = {
  #   zwave-js-ui = {
  #     image = "zwavejs/zwave-js-ui:latest";
  #     ports = [ "8091:8091" "3000:3000" ];
  #     pull = "newer";
  #     devices = [
  #       "/dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00:/dev/zwave"
  #     ];
  #     volumes = [
  #       "zwave-js-ui:/usr/src/app/store"
  #     ];
  #     extraOptions = ["--network=host"];
  #   };
  # };

  # networking.firewall.allowedTCPPorts = [ 8091 3000 ];

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   autoPrune.enable = true;
  # };
}
