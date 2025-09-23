# report a service's success/failure to healthchecks.io
# each template is instantiated with the name of the unit being reported on and the action (start, success, failure)
# example: healthchecks-ping@restic-backups-system-backup:start, ...
{
  config,
  lib,
  pkgs,
  ...
}:
let
  allowableActions = [
    "start"
    "success"
    "fail"
    "stop"
  ];
  rawCfg = config.services.healthchecks-ping;
  cfg = lib.filterAttrs (_: v: (v.enable or true) && (v.urlFile != null || v.url != null)) rawCfg;
  configuredUnits = lib.filterAttrs (_: v: v.unitName != null) cfg;
  credentialFiles = lib.listToAttrs (
    lib.mapAttrsToList (
      n: v:
      let
        unit = if v.unitName != null then v.unitName else n;
        fileName = "healthchecks-${lib.replaceStrings [ "@" ] [ "-" ] unit}";
        content = lib.concatStringsSep "\n" (
          [ "HC_URL=${v.url}" ]
          ++ lib.optionals (v.defaultSendLogs != null) [
            "HC_SEND_LOGS=${if v.defaultSendLogs then "1" else "0"}"
          ]
          ++ lib.optionals (v.defaultMaxLogLines != null) [
            "HC_MAX_LOG_LINES=${toString v.defaultMaxLogLines}"
          ]
        );
      in
      {
        name = unit;
        value = if v.url != null then pkgs.writeText fileName (content + "\n") else v.urlFile;
      }
    ) cfg
  );
  loadCredentials = lib.mapAttrsToList (unit: path: "${unit}:${path}") credentialFiles;
  systemctlCmd = lib.getExe' config.systemd.package "systemctl";
in
{
  options.services.healthchecks-ping = lib.mkOption {
    description = ''
      Send pings to healthchecks.io when services start/stop/fail.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (_: {
        options = {
          enable = lib.mkEnableOption "Send pings to healthchecks.io";

          urlFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            description = ''
              Read the healthcheck URL from a file.
              Must be in the EnvironmentFile format, with name HC_URL.
              Additional variables can be set in the same file.
              ```
              HC_URL=https://hc-ping.com/12345678-1234-1234-1234-1234567890ab
              ...
              ```
              Optional keys recognised by the helper include ``HC_TIMEOUT`` (seconds, defaults to 10),
              ``HC_RETRY`` (curl retry count, defaults to 3), ``HC_SEND_LOGS`` (set to 0 to disable
              attaching logs on success/fail) and ``HC_MAX_LOG_LINES`` (truncate journal output).
            '';
            default = null;
            example = "/var/run/agenix/healthchecks";
          };
          url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = ''
              URL to send start/stop/fail messages to.
            '';
            default = null;
            example = "https://hc-ping.com/12345678-1234-1234-1234-1234567890ab";
          };
          unitName = lib.mkOption {
            description = ''
              Name of the unit to add Wants/OnSuccess/OnFailure dependencies to.
            '';
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "restic-backups-system-backup";
          };
          actions = lib.mkOption {
            description = ''
              Which lifecycle events should emit healthchecks.io pings when ``unitName`` is provided.
              ``start`` sends a ping before the unit's main process runs, ``success`` runs on OnSuccess, ``fail`` on OnFailure, and ``stop`` during the unit's postStop hook.
            '';
            type = lib.types.listOf (lib.types.enum allowableActions);
            default = [
              "start"
              "success"
              "fail"
            ];
            example = [
              "start"
              "success"
              "fail"
              "stop"
            ];
          };
          defaultSendLogs = lib.mkOption {
            description = ''
              When set, control whether success/fail actions include the triggering unit's journal logs by default.
              Can be overridden in the credentials file via ``HC_SEND_LOGS``.
            '';
            type = lib.types.nullOr lib.types.bool;
            default = null;
          };
          defaultMaxLogLines = lib.mkOption {
            description = ''
              Optional default cap on log lines collected for success/fail events.
              Override via ``HC_MAX_LOG_LINES`` inside the credentials file.
            '';
            type = lib.types.nullOr lib.types.int;
            default = null;
            example = 200;
          };
        };
        config = {
          actions = lib.mkDefault [
            "start"
            "success"
            "fail"
          ];
        };
      })
    );
    default = { };
  };

  config = lib.mkIf (cfg != { }) {
    assertions =
      lib.mapAttrsToList (n: v: {
        assertion = (v.urlFile == null) != (v.url == null);
        message = "services.healthchecks.${n}: exactly one of url or urlFile should be set";
      }) cfg
      ++ lib.mapAttrsToList (n: v: {
        assertion = config.systemd.services ? "${v.unitName}";
        message = "services.healthchecks.${n}: unitName ${v.unitName} does not correspond to a configured systemd unit";
      }) configuredUnits
      ++ lib.mapAttrsToList (n: v: {
        assertion = v.actions != [ ];
        message = "services.healthchecks.${n}: actions must contain at least one entry when unitName is set";
      }) (lib.filterAttrs (_: v: v.unitName != null) cfg)
      ++ lib.mapAttrsToList (_: v: {
        assertion = builtins.all (action: lib.elem action allowableActions) v.actions;
        message = "services.healthchecks: unsupported action specified";
      }) cfg;

    systemd.services = lib.mkMerge [
      (lib.mapAttrs' (
        _name: val:
        lib.nameValuePair val.unitName {
          wants = lib.optionals (lib.elem "start" val.actions) [
            "healthchecks-ping@${val.unitName}:start.service"
          ];
          onSuccess = lib.optionals (lib.elem "success" val.actions) [
            "healthchecks-ping@${val.unitName}:success.service"
          ];
          onFailure = lib.optionals (lib.elem "fail" val.actions) [
            "healthchecks-ping@${val.unitName}:fail.service"
          ];
          postStop = lib.mkAfter (
            lib.optionalString (lib.elem "stop" val.actions) ''
              ${systemctlCmd} start --no-block ${lib.escapeShellArg "healthchecks-ping@${val.unitName}:stop.service"} || true
            ''
          );
        }
      ) configuredUnits)
      {
        "healthchecks-ping@" = {
          description = "Pings healthchecks.io (%i)";
          serviceConfig = {
            Type = "oneshot";
            LoadCredential = loadCredentials;
            # Hardening
            DynamicUser = true;
            ProtectSystem = "strict";
            ProtectHome = "read-only";
            PrivateTmp = true;
            RestrictSUIDSGID = true;
            PrivateDevices = true; # Only allow access to pseudo-devices (eg: null, random, zero) in separate namespace
            PrivateUsers = true;
            SupplementaryGroups = "systemd-journal"; # Allow access to journal
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
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
            CapabilityBoundingSet = [ ];
            AmbientCapabilities = [ ];
            NoNewPrivileges = true;
            KeyringMode = "private";
            ProtectHostname = true;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            RemoveIPC = true;
            UMask = "0077";
          };
          scriptArgs = "%i"; # name:action
          script = ''
            set -euo pipefail

            IFS=':' read -r unit action <<< "$1"

            case "$action" in
              start|success|fail|stop) ;;
              *)
                echo "Unsupported healthchecks action '$action'" >&2
                exit 1
                ;;
            esac

            credentials_file="$CREDENTIALS_DIRECTORY/$unit"
            if [ ! -r "$credentials_file" ]; then
              echo "Credentials file $credentials_file is missing or unreadable" >&2
              exit 1
            fi

            # shellcheck disable=SC1090
            . "$credentials_file"

            : "''${HC_URL:?HC_URL must be defined in $credentials_file}"

            timeout="''${HC_TIMEOUT:-10}"
            retries="''${HC_RETRY:-3}"
            send_logs="''${HC_SEND_LOGS:-1}"
            max_lines="''${HC_MAX_LOG_LINES:-200}"

            ping_url="$HC_URL"
            if [ "$action" != "success" ]; then
              ping_url="$HC_URL/$action"
            fi

            payload=""

            if [ "$send_logs" = "1" ] && { [ "$action" = "success" ] || [ "$action" = "fail" ]; }; then
              invocation_id="$(systemctl show -p InvocationID --value "$unit.service" 2>/dev/null || true)"
              if [ -n "$invocation_id" ] && [ "$invocation_id" != "n/a" ]; then
                payload="$(journalctl _SYSTEMD_INVOCATION_ID="$invocation_id" --no-pager --output=cat --lines "$max_lines" 2>/dev/null || true)"
              else
                payload="$(journalctl --unit "$unit.service" --no-pager --output=cat --lines "$max_lines" 2>/dev/null || true)"
              fi
            fi

            if [ -n "$payload" ]; then
              printf '%s' "$payload" | ${lib.getExe pkgs.curl} -fsS -m "$timeout" --retry "$retries" --data-binary @- "$ping_url"
            else
              ${lib.getExe pkgs.curl} -fsS -m "$timeout" --retry "$retries" "$ping_url"
            fi
          '';
        };
      }
    ];
  };
}
