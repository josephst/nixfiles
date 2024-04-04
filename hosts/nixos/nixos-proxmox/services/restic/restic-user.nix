{ config, pkgs, ... }:
{
  users.users.restic = {
    isSystemUser = true;
    group = "restic";
    # home = cfg.dataDir;
    createHome = false;
    uid = config.ids.uids.restic;
    extraGroups = [ "systemd-journal" ]; # to view journals and send to healthchecks.io
  };

  users.groups.restic.gid = config.ids.uids.restic;
}
