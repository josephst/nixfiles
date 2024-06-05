{ config, ... }:
{
  users.users.restic = {
    group = "restic";
    createHome = true;
    uid = config.ids.uids.restic;
    extraGroups = [ "systemd-journal" ]; # to view journals and send to healthchecks.io
  };

  users.groups.restic.gid = config.ids.uids.restic;
}
