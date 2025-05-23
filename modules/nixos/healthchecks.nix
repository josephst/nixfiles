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
  cfg = lib.filterAttrs (_: v: v.urlFile != null || v.url != null) config.services.healthchecks-ping;
  urlFiles = lib.mapAttrsToList (n: v: {
    name = if v.unitName != null then v.unitName else n;
    path = if v.url != null then (pkgs.writeText "healthchecks-${n}" "HC_URL=${v.url}") else v.urlFile;
  }) cfg;
in
{
  options.services.healthchecks-ping = lib.mkOption {
    description = ''
      Send pings to healthchecks.io when services start/stop/fail.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (_: {
        options = {
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
      }) (lib.filterAttrs (_: v: v.unitName != null) cfg);

    systemd.services = lib.mkMerge [
      (lib.mapAttrs' (
        _name: val:
        lib.nameValuePair val.unitName {
          wants = [ "healthchecks-ping@${val.unitName}:start.service" ];
          onSuccess = [ "healthchecks-ping@${val.unitName}:success.service" ];
          onFailure = [ "healthchecks-ping@${val.unitName}:fail.service" ];
        }
      ) (lib.filterAttrs (_: v: v.unitName != null) cfg))
      {
        "healthchecks-ping@" = {
          description = "Pings healthchecks.io (%i)";
          serviceConfig = {
            Type = "oneshot";
            LoadCredential = builtins.map ({ name, path }: "${name}:${path}") urlFiles;
            # Hardening
            # DynamicUser = true; # disabled, because call to `systemctl show` requires root privileges
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
          };
          scriptArgs = "%i"; # name:action
          # requires systemd v257 (journalctl has -I flag for latest invocation)
          script = ''
            # set -x # for debugging
            IFS=':' read -r name action <<< "$1"

            # read the value of HC_URL from the file (file may contain other variables too)
            url=$(grep -oP "^HC_URL=\K.+" "$CREDENTIALS_DIRECTORY/$name")

            if [ "$action" = "success" ]; then
              logs=$(journalctl -I -u "$name.service" --no-pager)
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-raw "$logs" "$url"
            elif [ "$action" = "fail" ]; then
              logs=$(journalctl -I -u "$name.service" --no-pager)
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-raw "$logs" "$url/fail"
            else
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/$action"
            fi
          '';
        };
      }
    ];
  };
}
