_: {
  services.matterjs-server = {
    enable = true;
  };

  services.restic.backups.system-backup.paths = [
    "/var/lib/matterjs-server"
  ];
}
