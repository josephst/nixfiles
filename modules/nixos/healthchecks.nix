# report a service's success/failure to healthchecks.io
# this creates a systemd template unit for each service that reports to healthchecks.io
# each template is instantiated with the action (start, success, failure)
{ config, lib, pkgs, ... }:
{
  options.services.healthchecks-reporter = lib.mkOption {
    description = ''
      Send pings to healthchecks.io when services start/stop/fail.
    '';
    type = lib.types.attrsOf (lib.types.submodule (_: {
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
          example = "/var/run/agenix/healthchecks";
        };
        url = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = ''
            URL to send start/stop/fail messages to.
          '';
          example = "https://hc-ping.com/12345678-1234-1234-1234-1234567890ab";
        };
      };
    }));
    default = { };
  };

  config = {
    assertions = lib.mapAttrsToList
      (n: v: {
        assertion = (v.urlFile == null) != (v.url == null);
        message = "services.healthchecks.${n}: exactly one of url or urlFile should be set";
      })
      config.services.healthchecks-reporter;

    systemd.services = lib.mapAttrs'
      (name: val: {
        "healthcheck-ping-${name}@" = {
          description = "Pings healthcheck (%i)";
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = if (val.urlFile == null) then pkgs.writeText "healthchecks-${name}" "HC_URL=${val.url}" else val.urlFile;
          };
          scriptArgs = "%i";
          script = ''
            # set -x # for debugging

            IFS=':' read -r action <<< "$1"
            if [ "$action" = "success" ]; then
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$HC_URL"
            else
              ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$HC_URL/$action"
            fi
          '';
        };
      })
      config.services.healthchecks-reporter;
  };
}
