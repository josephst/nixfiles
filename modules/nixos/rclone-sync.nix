{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

# TODO: support lists (from multiple locations, to multiple locations)

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

    # TODO:
    # appendOnly (with rclone copy?)

    remoteDir = lib.mkOption {
      default = null;
      type = with lib.types; nullOr str;
      description = "The remote Rclone-supported backend to copy repository to";
      example = "b2:foobar/restic";
    };

    environmentFile = lib.mkOption {
      default = null;
      type = with lib.types; nullOr str;
      description = ''
        Path to a file containing the name of a remote \
        Rclone-supported backend to copy repository to.
        Using the usual systemd EnvironmentFile syntax.

        *Must* have key named "REMOTE"
        May also have HC_UUID set to provide UUID for healthchecks.io

        Example file:
        ```
        REMOTE=b2:example/rclone
        HC_UUID=<uuid>
        ```

        For this example, will need to make sure `b2` is a configured backend in rclone.conf
      '';
      example = "/var/run/agenix/rcloneRemoteDir";
    };

    extraRcloneArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "--transfers=16"
        "--b2-hard-delete"
        "--fast-list"
      ];
      description = ''
        Extra arguments passed to rclone
      '';
      example = [
        "--transfers=16"
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

    pingHealthchecks = lib.mkOption {
      type = lib.types.bool;
      description = "Try to ping start/stop and send logs to healthchecks.io. Set HC_UUID as environment variable (cfg.environmentFile) to configure.";
      default = false;
    };

    timerConfig = lib.mkOption {
      type = with lib.types; nullOr (attrsOf unitOption);
      default = {
        OnCalendar = "daily";
        Persistent = true;
      };
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
        assertion =
          (config.services.rclone-sync.remoteDir == null)
          != (config.services.rclone-sync.environmentFile == null);
        message = "exactly one of remoteDir or environmentFile cannot be null";
      }
      {
        assertion = config.services.rclone-sync.rcloneConfFile != null;
        message = "must provide a Rclone config file";
      }
    ];

    systemd.services.rclone-sync = {
      description = "Copy local dir (mainly a Restic repo) to remote, using Rclone";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig =
        let
          remote = if cfg.remoteDir != null then cfg.remoteDir else "$REMOTE";
          extraArgs = utils.escapeSystemdExecArgs cfg.extraRcloneArgs;
        in
        {
          LoadCredential = "rcloneConf:${cfg.rcloneConfFile}";
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${cfg.package}/bin/rclone --config=\${CREDENTIALS_DIRECTORY}/rcloneConf sync ${cfg.dataDir} ${remote} ${extraArgs}";

          Type = "oneshot";

          # Security hardening
          ReadWritePaths = [ cfg.dataDir ];
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          PrivateDevices = true;
        }
        // lib.optionalAttrs cfg.pingHealthchecks {
          ExecStartPre = ''-${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/''${HC_UUID}/start"'';
          onSuccess = [ "rclone-sync-notify@success.service" ];
          onFailure = [ "rclone-sync-notify@failure.service" ];
        };
    };

    systemd.services."rclone-sync-notify@" = lib.mkIf cfg.pingHealthchecks {
      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        User = "restic"; # to read env file
        ExecStart = "${pkgs.healthchecks-ping}/bin/healthchecks-ping $HC_UUID $MONITOR_EXIT_STATUS $MONITOR_UNIT";
      };
    };

    systemd.timers = lib.mkIf (cfg.timerConfig != null) {
      rclone-sync = {
        wantedBy = [ "timers.target" ];
        inherit (cfg) timerConfig;
      };
    };
  };
}
