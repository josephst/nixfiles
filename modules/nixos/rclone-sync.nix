{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.rclone-sync;
  inherit (utils.systemdUtils.unitOptions) unitOption;
in
{
  meta.maintainers = [ lib.maintainers.josephst ];

  options.services.rclone-sync = {
    enable = lib.mkEnableOption "Sync Restic repos to B2 using Rclone (ie will also delete from remote)";

    dataDir = lib.mkOption {
      default = "/srv/restic/";
      type = lib.types.str;
      description = "The local restic repository to be copied from.";
    };

    environmentFile = lib.mkOption {
      default = null;
      type = with lib.types; str;
      description = ''
        Path to a file containing HC_UUID set to provide UUID for healthchecks.io
        If using Rclone env_auth (ie environmental variables) to authenticate with remote,
        they should also be configured here

        Also set $REMOTE here to provide the remote (in Rclone syntax) and bucket/ folder name

        Example file:
        ```
        REMOTE=remote:bucketName/folderName
        HC_UUID=<uuid>
        AWS_SECRET_KEY_ID=...
        ...
        ```

        For this example, will need to make sure `b2` is a configured backend in rclone.conf
      '';
      example = "/var/run/agenix/rcloneRemoteDir";
    };

    extraRcloneArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "--transfers=32"
        "--b2-hard-delete"
        "--fast-list"
      ];
      description = ''
        Extra arguments passed to rclone
      '';
      example = [
        "--transfers=32"
        "--b2-hard-delete"
        "--fast-list"
      ];
    };

    rcloneConfFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to `rclone.conf` file (must be readable by same user as this service)";
      example = "/var/run/agenix/rcloneConf";
      default = "/etc/rclone.conf";
    };

    timerConfig = lib.mkOption {
      type = with lib.types; nullOr (attrsOf unitOption);
      default = null;
      description = ''
        When to run rclone. See {manpage}`systemd.timer(5)` for
        details. If null no timer is created and rclone will only
        run when explicitly started.
      '';
      example = {
        OnCalendar = "06:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    package = lib.mkPackageOption pkgs "rclone" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.rclone-sync.dataDir != null;
        message = "services.rclone-sync.dataDir must be a valid path";
      }
      {
        assertion = config.services.rclone-sync.rcloneConfFile != null;
        message = "must provide a Rclone conf file";
      }
    ];

    systemd.services.rclone-sync =
      let
        extraArgs = lib.escapeShellArgs cfg.extraRcloneArgs;
      in
      {
        description = "Copy local dir (mainly a Restic repo) to remote, using Rclone";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          LoadCredential = [ "rcloneConf:${cfg.rcloneConfFile}" ];
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          # Security hardening
          DynamicUser = true;
          ReadOnlyPaths = [ cfg.dataDir ]; # need to be able to read the backup dir
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          PrivateDevices = true;
          StateDirectory = "rclone-sync";
          CacheDirectory = "rclone-sync";
          CacheDirectoryMode = "0700";
        };

        script = ''
          ${cfg.package}/bin/rclone \
            --config "$CREDENTIALS_DIRECTORY/rcloneConf" \
            --cache-dir /var/cache/rclone-sync \
            --missing-on-dst - \
            --error - \
            sync "${cfg.dataDir}" "$REMOTE" ${extraArgs}
        '';
      };

    systemd.timers = lib.mkIf (cfg.timerConfig != null) {
      rclone-sync = {
        wantedBy = [ "timers.target" ];
        inherit (cfg) timerConfig;
      };
    };
  };
}
