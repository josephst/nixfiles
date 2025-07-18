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

  options.services.rclone-sync = with lib;
    mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkEnableOption "Sync a local directory to a remote using Rclone";

          dataDir = mkOption {
            type = types.str;
            description = "The local directory to be copied from.";
            example = "/srv/restic";
          };

          remote = mkOption {
            type = types.str;
            description = "The remote (in Rclone syntax) and bucket/folder name.";
            example = "b2:bucketName/folderName";
          };

          environmentFile = mkOption {
            default = null;
            type = with types;
              nullOr str;
            description = ''
              Path to a file containing HC_UUID set to provide UUID for healthchecks.io
              If using Rclone env_auth (ie environmental variables) to authenticate with remote,
              they should also be configured here
            '';
            example = "/var/run/agenix/rcloneRemoteDir";
          };

          extraRcloneArgs = mkOption {
            type = with types; listOf str;
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

          rcloneConfFile = mkOption {
            type = types.str;
            description = "Path to `rclone.conf` file (must be readable by same user as this service)";
            example = "/var/run/agenix/rcloneConf";
            default = "/etc/rclone.conf";
          };

          timerConfig = mkOption {
            type = with types; nullOr (attrsOf unitOption);
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

          package = mkPackageOption pkgs "rclone" { };
        };
      }));
    };

  config =
    let
      mkService =
        name: cfg:
        {
          name = "rclone-sync-${name}";
          value = {
            description = "Copy local dir (mainly a Restic repo) to remote, using Rclone";
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              LoadCredential = [ "rcloneConf:${cfg.rcloneConfFile}" ];
              EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
              # Security hardening
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
                sync "${cfg.dataDir}" "${cfg.remote}" ${lib.escapeShellArgs cfg.extraRcloneArgs}
            '';
          };
        };

      mkTimer =
        name: cfg:
        {
          name = "rclone-sync-${name}";
          value = {
            wantedBy = [ "timers.target" ];
            timerConfig = cfg.timerConfig;
          };
        };

      services = builtins.mapAttrs mkService (lib.filterAttrs (n: v: v.enable) cfg);
      timers = builtins.mapAttrs mkTimer (lib.filterAttrs (n: v: v.enable && v.timerConfig != null) cfg);
    in
    {
      assertions = lib.flatten (builtins.mapAttrsToList (
        name: value: [
          {
            assertion = value.dataDir != null;
            message = "services.rclone-sync.${name}.dataDir must be a valid path";
          }
          {
            assertion = value.rcloneConfFile != null;
            message = "services.rclone-sync.${name}.rcloneConfFile must provide a Rclone conf file";
          }
        ]
      ) cfg);

      systemd.services = services;
      systemd.timers = timers;
    };
}
