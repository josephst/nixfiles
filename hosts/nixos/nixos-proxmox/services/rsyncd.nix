{config, ...}: {
  age.secrets.rsyncd = {
    file = ../../../../secrets/rsyncd.age;
  };

  services.rsyncd = {
    enable = false;
    settings = {
      global = {
        # user = "rsyncd";
        # group = "rsyncd";
        "use chroot" = false;
      };
      nas = {
        comment = "NAS rsyncd dir";
        path = "/mnt/exthdd/nas-rsyncd/";
        "auth users" = "backup";
        "secrets file" = config.age.secrets.rsyncd.path;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 873 ];

  # systemd.tmpfiles.rules = [
  #   "d  /mnt/exthdd/nas-rsyncd/ 0755  root  root"
  # ]

  users.users.rsyncd = {
    isSystemUser = true;
    group = "rsyncd";
  };

  users.groups.rsyncd = {};

  systemd.services.rsyncd.serviceConfig = {
    AmbientCapabilities = "cap_net_bind_service";
  };
}
