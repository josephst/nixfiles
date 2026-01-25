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
    name = n;
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
        };
      })
    );
    default = { };
  };

  config = lib.mkIf (cfg != { }) {
    assertions =
      lib.mapAttrsToList (n: v: {
        assertion = (v.urlFile == null) != (v.url == null);
        message = "services.healthchecks-ping.${n}: exactly one of url or urlFile should be set";
      }) cfg
      ++ lib.mapAttrsToList (n: _: {
        assertion = lib.hasAttr n config.systemd.services;
        message = "services.healthchecks-ping.${n}: no matching systemd service found";
      }) cfg;

    systemd.services = lib.mkMerge [
      (lib.mapAttrs' (
        name: _val:
        lib.nameValuePair name {
          wants = [ "healthchecks-ping@${name}:start.service" ];
          onSuccess = [ "healthchecks-ping@${name}:success.service" ];
          onFailure = [ "healthchecks-ping@${name}:fail.service" ];
        }
      ) cfg)
      {
        "healthchecks-ping@" = {
          description = "Pings healthchecks.io (%i)";
          serviceConfig = {
            Type = "oneshot";
            LoadCredential = map ({ name, path }: "${name}:${path}") urlFiles;
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
              # last 1000 lines
              logs=$(journalctl -I -u "$name.service" -n 1000 --no-pager --output=short-iso)
              echo "$logs" | ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-binary @- "$url"
            elif [ "$action" = "fail" ]; then
              logs=$(journalctl -I -u "$name.service" -n 1000 --no-pager --output=short-iso)
              echo "$logs" | ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-binary @- "$url/fail"
            else
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/$action"
            fi
          '';
        };
      }
    ];
  };
}
