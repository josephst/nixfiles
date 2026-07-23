{
  lib,
  utils,
  ...
}:
let
  mountUnit = path: "${utils.escapeSystemdPath path}.mount";
  homesMount = mountUnit "/storage/homes";
  mediaMount = mountUnit "/storage/media";
  resticMount = mountUnit "/storage/restic";
  storageMount = mountUnit "/storage";
in
{
  # Shared ownership for services that read from or write to media storage.
  users.groups.media = { };

  # New directories inherit the media group. Cooperative service umasks keep
  # files and directories writable by the other media services.
  systemd.tmpfiles.settings."10-media" = {
    "/storage/media".d = {
      user = "root";
      group = "media";
      mode = "2775";
    };
    "/storage/media/usenet".d = {
      user = "sabnzbd";
      group = "media";
      mode = "2775";
    };
  };

  systemd.services = {
    backrest = {
      bindsTo = [ storageMount ];
      unitConfig.RequiresMountsFor = [ "/storage" ];
    };

    copyparty = {
      bindsTo = [
        storageMount
        mediaMount
      ];
      unitConfig.RequiresMountsFor = [ "/storage/media" ];
    };

    jellyfin.unitConfig = {
      WantsMountsFor = [ "/storage/media" ];
      AssertPathIsMountPoint = [ "/storage/media" ];
    };

    radarr = {
      bindsTo = [ mediaMount ];
      unitConfig.RequiresMountsFor = [ "/storage/media" ];
      serviceConfig.UMask = lib.mkForce "0002";
    };

    rclone-sync-b2.bindsTo = [ resticMount ];

    restic-rest-server = {
      bindsTo = [ resticMount ];
      unitConfig.RequiresMountsFor = [ "/storage/restic" ];
    };

    sabnzbd = {
      bindsTo = [ mediaMount ];
      unitConfig.RequiresMountsFor = [ "/storage/media" ];
      serviceConfig.UMask = lib.mkForce "0002";
    };

    samba-smbd = {
      requires = [ "samba-setup.service" ];
      bindsTo = [
        homesMount
        mediaMount
      ];
      unitConfig.RequiresMountsFor = [
        "/storage/homes/public"
        "/storage/media"
      ];
    };

    sonarr = {
      bindsTo = [ mediaMount ];
      unitConfig.RequiresMountsFor = [ "/storage/media" ];
      serviceConfig.UMask = lib.mkForce "0002";
    };
  };
}
