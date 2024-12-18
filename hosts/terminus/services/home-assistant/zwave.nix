{ ... }: {
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