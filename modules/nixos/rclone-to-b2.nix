{ config, lib, pkgs, utils, ... }:

with lib;

# TODO: support lists (from multiple locations, to multiple locations)

let
  cfg = config.services.restic.clone;
in
{
  meta.maintainers = [ maintainers.josephst ];

  options.services.restic.clone = {
    enable = mkEnableOption (lib.mdDoc "Sync Restic repos to B2 using Rclone (ie will also delete from remote)");

    dataDir = mkOption {
      default = "/var/lib/restic/";
      type = types.str;
      description = lib.mdDoc "The local restic repository to be copied from.";
    };

    # TODO:
    # appendOnly (with rclone copy?)

    remoteDir = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = lib.mdDoc "The remote Rclone-supported backend to copy repository to";
      example = "b2:foobar/restic";
    };

    remoteDirFile = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = lib.mdDoc ''
        Path to a file containing the name of a remote \
        Rclone-supported backend to copy repository to. 
        Using the usual systemd EnvironmentFile syntax.

        *Must* have key named "REMOTE"
        
        Example file:
        ```
        REMOTE=b2:example/rclone
        ```

        For this example, will need to make sure `b2` is a configured backend in rclone.conf
        '';
      example = "/var/run/agenix/rcloneRemoteDir";
    };

    extraRcloneArgs = mkOption {
      type = types.listOf types.str;
      default = [ "--transfers=16" "--b2-hard-delete" ];
      description = lib.mdDoc ''
        Extra arguments passed to rclone
      '';
      example = [
        "--transfers=16" "--b2-hard-delete"
      ];
    };

    rcloneConfFile = mkOption {
      type = types.str;
      description = lib.mdDoc "Path to rclone.conf file (must be readable by same user as this service)";
      example = "/var/run/agenix/rcloneConf";
      default = "/etc/rclone.conf";
    };

    package = mkPackageOption pkgs "rclone" { };
  };

  config = mkIf cfg.enable {
    assertions = [
      { assertion = (config.services.restic.clone.dataDir != null);
        message = "services.restic.clone.dataDir must be a valid path";
      } {
        assertion = (config.services.restic.clone.remoteDir == null) != (config.services.restic.clone.remoteDirFile == null);
        message = "exactly one of remoteDir or remoteDirFile cannot be null";
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
      } // lib.optionalAttrs (cfg.remoteDirFile != null) {
        EnvironmentFile = cfg.remoteDirFile;
      };
    };

    users.users.restic = {
      group = "restic";
      home = cfg.dataDir;
      createHome = false;
      uid = config.ids.uids.restic;
    };

    users.groups.restic.gid = config.ids.uids.restic;
  };
}
