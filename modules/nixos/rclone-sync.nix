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

  options.services.rclone-sync = lib.mkOption {
    description = ''
      Periodic copies of a local directory to an Rclone remote
    '';
    type =
      with lib;
      types.attrsOf (
        types.submodule (_: {
          options = {
            enable = mkEnableOption "Sync a local directory to a remote using Rclone";

            dataDir = mkOption {
              type = types.str;
              description = "The local directory to be copied from.";
              example = "/srv/restic";
            };

            environmentFile = mkOption {
              default = null;
              type = with types; nullOr str;
              description = ''
                Path to a file containing environment variables consumed by the sync job.
                At a minimum this can export ``REMOTE`` (the full rclone destination, e.g. ``myremote:bucket/path``)
                and optional healthchecks.io settings such as ``HC_URL``.
                Populate any credential-specific variables (for example AWS keys) here as well.
              '';
              example = "/var/run/agenix/rcloneRemoteDir";
            };

            remote = mkOption {
              type = with types; nullOr str;
              default = null;
              description = ''
                Target rclone remote (``remote:path``) to sync into. When unset the service expects
                ``REMOTE`` to be provided via ``environmentFile`` or another mechanism.
              '';
              example = "b2:my-bucket/restic";
            };

            user = mkOption {
              type = with types; nullOr str;
              default = null;
              description = ''
                Optional system user to run the sync under. Defaults to ``root``. Ensure this user has
                read access to ``dataDir``.
              '';
            };

            group = mkOption {
              type = with types; nullOr str;
              default = null;
              description = "Optional group to run the sync under.";
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

            healthcheck = mkOption {
              type =
                with types;
                nullOr (
                  submodule (_: {
                    options = {
                      enable = mkEnableOption "Emit status updates to healthchecks.io";

                      url = mkOption {
                        type = with types; nullOr str;
                        default = null;
                        description = "Direct healthchecks.io URL to ping.";
                      };

                      urlFile = mkOption {
                        type = with types; nullOr path;
                        default = null;
                        description = "Path to file exporting ``HC_URL`` and related settings.";
                      };
                    };
                  })
                );
              default = null;
              description = ''
                Configure optional healthchecks.io integration. This automatically provisions a
                ``services.healthchecks-ping`` entry targeting the sync unit when enabled.
              '';
            };
          };
        })
      );
    default = { };
  };

  config = {
    assertions =
      lib.mapAttrsToList (name: value: {
        assertion = value.dataDir != null;
        message = "services.rclone-sync.${name}.dataDir must be a valid path";
      }) cfg
      ++ lib.mapAttrsToList (
        name: value: {
          assertion =
            value.healthcheck == null
            || !value.healthcheck.enable
            || ((value.healthcheck.urlFile == null) != (value.healthcheck.url == null));
          message = "services.rclone-sync.${name}.healthcheck: set url or urlFile (but not both) when enabled";
        }
      );

    systemd.services = lib.mapAttrs' (
      name: remoteConfig:
      let
        unitName = "rclone-sync-${name}";
        sanitizedName = lib.strings.sanitizeDerivationName name;
      in
      lib.nameValuePair unitName {
        description = "Rclone sync for '${name}' from ${remoteConfig.dataDir}";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        environment = lib.optionalAttrs (remoteConfig.remote != null) { REMOTE = remoteConfig.remote; };
        serviceConfig = {
          Type = "oneshot";
          LoadCredential = [ "rcloneConf:${remoteConfig.rcloneConfFile}" ];
          EnvironmentFile = lib.optionals (remoteConfig.environmentFile != null) [
            remoteConfig.environmentFile
          ];
          # Security hardening
          ReadOnlyPaths = [ remoteConfig.dataDir ]; # need to be able to read the backup dir
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          PrivateDevices = true;
          PrivateUsers = true;
          NoNewPrivileges = true;
          CapabilityBoundingSet = [ ];
          AmbientCapabilities = [ ];
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          RemoveIPC = true;
          KeyringMode = "private";
          UMask = "0077";
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelLogs = true;
          ProtectProc = "invisible";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service";
          SystemCallErrorNumber = "EPERM";
          StateDirectory = "rclone-sync/${sanitizedName}";
          CacheDirectory = "rclone-sync/${sanitizedName}";
          CacheDirectoryMode = "0700";
        }
        // lib.optionalAttrs (remoteConfig.user != null) { User = remoteConfig.user; }
        // lib.optionalAttrs (remoteConfig.group != null) { Group = remoteConfig.group; };

        script = ''
          set -euo pipefail

          if [ -z "''${REMOTE:-}" ]; then
            echo "REMOTE destination not provided for ${unitName}" >&2
            exit 1
          fi

          ${remoteConfig.package}/bin/rclone \
            --config "$CREDENTIALS_DIRECTORY/rcloneConf" \
            --cache-dir "$CACHE_DIRECTORY" \
            --missing-on-dst - \
            --error - \
            sync "${remoteConfig.dataDir}" "$REMOTE" ${lib.escapeShellArgs remoteConfig.extraRcloneArgs}
        '';
      }
    ) (lib.filterAttrs (_n: v: v.enable) cfg);

    services.healthchecks-ping = lib.mkMerge [
      (lib.mapAttrs'
        (
          name: remoteConfig:
          let
            hc = remoteConfig.healthcheck;
            unitName = "rclone-sync-${name}";
            entryName = unitName;
          in
          lib.nameValuePair entryName {
            inherit (hc) url;
            inherit (hc) urlFile;
            inherit unitName;
          }
        )
        (
          lib.filterAttrs (
            _: remoteConfig:
            remoteConfig.enable && remoteConfig.healthcheck != null && remoteConfig.healthcheck.enable
          ) cfg
        )
      )
    ];

    systemd.timers = lib.mapAttrs' (
      name: remoteConfig:
      lib.nameValuePair "rclone-sync-${name}" {
        wantedBy = [ "timers.target" ];
        inherit (remoteConfig) timerConfig;
      }
    ) (lib.filterAttrs (_n: v: v.enable && v.timerConfig != null) cfg);
  };
}
