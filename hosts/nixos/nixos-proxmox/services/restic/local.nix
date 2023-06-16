{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  forgetOpts = "--keep-daily 30 --keep-weekly 52 --keep-monthly 24 --keep-yearly 10 --keep-tag forever";
  checkOpts = "--read-data-subset 5%";
  uuid = "f7536950-d7a4-41f1-b1c2-959f0cf40fd3";
  resticRepo = "rest:https://restic.${fqdn}";
in {
  # config .env file containing RESTIC_PASSWORD=...
  age.secrets.resticLanEnv = {
    file = ../../../../../secrets/resticLan.env.age;
  };

  systemd.services.restic-nas-maintenance = {
    description = "Restic maintenance (forget, prune, check) on NAS";
    wants = ["healthchecks@${uuid}:start:%n.service"];
    onFailure = ["healthchecks@${uuid}:failure:%n.service"];
    onSuccess = ["healthchecks@${uuid}:success:%n.service"];
    serviceConfig = {
      # User = "restic";
      # Group = "restic";
      Type = "oneshot";
      RuntimeDirectory = "restic-local";
      CacheDirectory = "restic-local";
      CacheDirectoryMode = "0700";
      EnvironmentFile = config.age.secrets.resticLanEnv.path;
      ExecStart = [
        "${pkgs.restic}/bin/restic -r ${resticRepo} forget ${forgetOpts} --prune --cache-dir=%C/restic-local"
        "${pkgs.restic}/bin/restic -r ${resticRepo} check ${checkOpts} --cache-dir=%C/restic-local"
      ];

      # hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      DevicePolicy = "closed";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };

  systemd.timers.restic-nas-maintenance = {
    description = "Run Restic local-specific maintenance (forget, prune, check) at 1:00 AM +/- 1hr";
    timerConfig = {
      OnCalendar = "*-*-* 1:00:00";
    };
    wantedBy = ["timers.target"];
  };
}
