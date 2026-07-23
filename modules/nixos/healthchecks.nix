# report a service's success/failure to healthchecks.io
# each monitored unit gets dedicated start, success, and failure ping services
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.healthchecks-ping;
  isValid = value: (value.urlFile == null) != (value.url == null);
  validCfg = lib.filterAttrs (_: isValid) cfg;
  actions = [
    "start"
    "success"
    "fail"
  ];
  pingServiceName = name: action: "healthchecks-ping-${name}-${action}";
  urlFile =
    name: value:
    if value.url != null then
      pkgs.writeText "healthchecks-${name}" "HC_URL=${value.url}"
    else
      value.urlFile;
  pingServices = lib.listToAttrs (
    lib.concatLists (
      lib.mapAttrsToList (
        name: value:
        map (
          action:
          lib.nameValuePair (pingServiceName name action) {
            description = "Pings healthchecks.io for ${name} (${action})";
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              LoadCredential = [ "url:${urlFile name value}" ];
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
            # journalctl -I requires systemd v257.
            script = ''
              url=$(grep -oP "^HC_URL=\K.+" "$CREDENTIALS_DIRECTORY/url")

              if [ ${lib.escapeShellArg action} = success ]; then
                logs=$(journalctl -I -u ${lib.escapeShellArg "${name}.service"} -n 100 --no-pager --output=short-iso)
                echo "$logs" | ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-binary @- "$url"
              elif [ ${lib.escapeShellArg action} = fail ]; then
                logs=$(journalctl -I -u ${lib.escapeShellArg "${name}.service"} -n 100 --no-pager --output=short-iso)
                echo "$logs" | ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 --data-binary @- "$url/fail"
              else
                ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/${action}"
              fi
            '';
          }
        ) actions
      ) validCfg
    )
  );
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
    assertions = lib.mapAttrsToList (n: v: {
      assertion = isValid v;
      message = "services.healthchecks-ping.${n}: exactly one of url or urlFile should be set";
    }) cfg;

    systemd.services = lib.mkMerge [
      (lib.mapAttrs' (
        name: _val:
        lib.nameValuePair name {
          wants = [ "${pingServiceName name "start"}.service" ];
          onSuccess = [ "${pingServiceName name "success"}.service" ];
          onFailure = [ "${pingServiceName name "fail"}.service" ];
        }
      ) validCfg)
      pingServices
    ];
  };
}
