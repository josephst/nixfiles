# report a service's success/failure to healthchecks.io
# each template is instantiated with the name of the unit being reported on and the action (start, success, failure)
# example: healthchecks-ping@restic-backups-system-backup:start, ...
{ config, lib, pkgs, ... }:
{
  options.services.healthchecks-ping = lib.mkOption {
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
    }));
    default = { };
  };

  config =
    let
      cfg = lib.filterAttrs (_: v: v.urlFile != null || v.url != null) config.services.healthchecks-ping;
      urlFiles = lib.mapAttrsToList
        (n: v: {
          name = n;
          path = if v.url != null then (pkgs.writeText "healthchecks-${n}" "HC_URL=${v.url}") else v.urlFile;
        })
        cfg;
    in
    {
      assertions = lib.mapAttrsToList
        (n: v: {
          assertion = (v.urlFile == null) != (v.url == null);
          message = "services.healthchecks.${n}: exactly one of url or urlFile should be set";
        })
        cfg;

      systemd.services = lib.mkMerge [
        (lib.mapAttrs'
          (name: val: lib.nameValuePair
            val.unitName
            {
              wants = [ "healthchecks-ping@${name}:start.service" ];
              onSuccess = [ "healthchecks-ping@${name}:success.service" ];
              onFailure = [ "healthchecks-ping@${name}:failure.service" ];
            }
          )
          (lib.filterAttrs (_: v: v.unitName != null) cfg))
        {
          "healthchecks-ping@" = {
            description = "Pings healthchecks.io (%i)";
            serviceConfig = {
              Type = "oneshot";
              LoadCredential = builtins.map ({ name, path }: "${name}:${path}") urlFiles;
            };
            scriptArgs = "%i"; # name:action
            script = ''
              # set -x # for debugging
              IFS=':' read -r name action <<< "$1"

              # read the value of HC_URL from the file (file may contain other variables too)
              url=$(grep -oP "^HC_URL=\K.+" "$CREDENTIALS_DIRECTORY/$name")

              if [ "$action" = "success" ]; then
                ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url"
              else
                ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/$action"
              fi
            '';
          };
        }
      ];
    };
}
