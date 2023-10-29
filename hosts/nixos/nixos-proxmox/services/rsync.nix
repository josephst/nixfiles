{
  config,
  pkgs,
  ...
}: let
  backupPath = "/mnt/exthdd/nas-rsyncd";
in {
  services.rsyncd = {
    enable = true;
    settings = {
      global = {
        uid = "rsyncd";
        gid = "rsyncd";
        "use chroot" = false;
      };
      nas-backup = {
        comment = "Rsync share for Hyper Backup on NAS";
        path = backupPath;
        "auth users" = "hyperbackup:rw"; # read-write access for hyperbackup user
        "secrets file" = config.age.secrets.rsyncd-secrets.path;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 873 ];

  users.users.rsyncd = {
    isSystemUser = true;
    group = "rsyncd";
  };

  users.groups.rsyncd = {};

  systemd.tmpfiles.rules = [
    "d '${backupPath}' 0755 rsyncd rsyncd - -"
  ];

  systemd.services.rsyncd.serviceConfig = {
    AmbientCapabilities = "cap_net_bind_service";
  };
}
