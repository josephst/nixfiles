{ config, lib, pkgs, utils, ... }:

with lib;

# TODO: support lists (from multiple locations, to multiple locations)

let
  cfg = config.services.restic.clone;
  inherit (utils.systemdUtils.unitOptions) unitOption;

  stopScript = pkgs.writeShellScript "healthchecks" ''
    OUTPUT=$(${pkgs.systemd}/bin/systemctl status "rclone-copy.service" -l -n 1000 | ${pkgs.coreutils}/bin/tail --bytes 100000)
    HC_UUID=$1
    EXIT_STATUS=''${2:-0} # two single quotes are the escape sequence here

    ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$HC_UUID/$EXIT_STATUS" --data-raw "$OUTPUT"
  '';
in
{
  meta.maintainers = [ maintainers.josephst ];

  options.services.restic.clone = {
    enable = mkEnableOption ("Sync Restic repos to B2 using Rclone (ie will also delete from remote)");

    dataDir = mkOption {
      default = "/var/lib/restic/";
      type = types.str;
      description = "The local restic repository to be copied from.";
    };

    # TODO:
    # appendOnly (with rclone copy?)

    remoteDir = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "The remote Rclone-supported backend to copy repository to";
      example = "b2:foobar/restic";
    };

    environmentFile = mkOption {
      default = null;
      type = types.nullOr types.str;
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

    extraRcloneArgs = mkOption {
      type = types.listOf types.str;
      default = [ "--transfers=16" "--b2-hard-delete" ];
      description = ''
        Extra arguments passed to rclone
      '';
      example = [
        "--transfers=16" "--b2-hard-delete"
      ];
    };

    rcloneConfFile = mkOption {
      type = types.str;
      description = "Path to `rclone.conf` file (must be readable by same user as this service)";
      example = "/var/run/agenix/rcloneConf";
      default = "/etc/rclone.conf";
    };

    pingHealthchecks = mkOption {
      type = types.bool;
      description = "Try to ping start/stop and send logs to healthchecks.io. Set HC_UUID as environment variable (cfg.environmentFile) to configure.";
      default = false;
    };

    timerConfig = mkOption {
      type = types.nullOr (types.attrsOf unitOption);
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

    package = mkPackageOption pkgs "rclone" { };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = (config.services.restic.clone.dataDir != null);
        message = "services.restic.clone.dataDir must be a valid path";
      } {
        assertion = (config.services.restic.clone.remoteDir == null) != (config.services.restic.clone.environmentFile == null);
        message = "exactly one of remoteDir or environmentFile cannot be null";
      } {
        assertion = (config.services.restic.clone.rcloneConfFile != null);
        message = "must provide a Rclone config file";
      }
    ];

    systemd.services.rclone-copy = {
      description = "Copy local dir (mainly a Restic repo) to remote, using Rclone";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = let
        remote = if cfg.remoteDir != null then cfg.remoteDir else "$REMOTE";
        extraArgs = utils.escapeSystemdExecArgs cfg.extraRcloneArgs;
      in {
        LoadCredential = "rcloneConf:${cfg.rcloneConfFile}";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/rclone --config=\${CREDENTIALS_DIRECTORY}/rcloneConf sync ${cfg.dataDir} ${remote} ${extraArgs}";

        Type = "oneshot";
        User = "restic"; # TODO: allow configuation of user/group
        Group = "restic";

        # Security hardening
        ReadWritePaths = [ cfg.dataDir ];
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
      } // lib.optionalAttrs cfg.pingHealthchecks {
        ExecStartPre = ''-${pkgs.curl}/bin/curl -m 10 --retry 5 "https://hc-ping.com/''${HC_UUID}/start"'';
        ExecStopPost = "${stopScript} $HC_UUID $EXIT_STATUS";
      };
    };

    systemd.timers = mkIf (cfg.timerConfig != null) {
      rclone-copy = {
        wantedBy = [ "timers.target" ];
        timerConfig = cfg.timerConfig;
      };
    };

    users.users.restic = {
      group = "restic";
      home = cfg.dataDir;
      createHome = true;
      uid = config.ids.uids.restic;
    };

    users.groups.restic.gid = config.ids.uids.restic;
  };
}
