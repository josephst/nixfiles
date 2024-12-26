{ config, lib, ... }:
{
  # extend the restic module to also support reporting successes to healthchecks.io
  options.services.restic.backups = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (_: {
        options = {
          healthchecksUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              URL to send start/stop/fail messages to
            '';
            example = "https://hc-ping.com/12345678-1234-1234-1234-1234567890ab";
          };
          healthchecksFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to a file containing the healthchecks.io URL.
              A URL set in `healthchecksUrl` takes precedence.
            '';
            example = "/var/run/agenix/healthchecksUrl";
          };
        };
      })
    );
  };

  config = {
    # services.healthchecks-reporter.system-backup = {
    #   url = "https://hc-ping.com/12345678-1234-1234-1234-1234567890ab";
    # };
    # systemd.services = (lib.mapAttrs'
    #   (name: _backup:
    #     lib.nameValuePair "restic-backups-${name}" {
    #       wants = [ "healthcheck-ping@${name}:start.service" ];
    #       onSuccess = [ "healthcheck-ping@${name}:success.service" ];
    #       onFailure = [ "healthcheck-ping@${name}:failure.service" ];
    #     }
    #   )
    #   cfg) // {
    # "healthcheck-ping@" = {
    #   description = "Pings healthcheck (%i)";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     EnvironmentFile = healthcheckEnvFile;
    #   };
    #   scriptArgs = "%i";
    #   script = ''
    #     # set -x # for debugging

    #     IFS=':' read -r name action <<< "$1"
    #     name="''${name^^}" # capitalize
    #     name="''${name//-/_}" # replace hyphens with underscores
    #     url="''${!name}" # urls are loaded fron EnvironmentFile

    #     if [ "$action" = "success" ]; then
    #       ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url"
    #     else
    #       ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/$action"
    #     fi
    #   '';
    # };
    # };
  };
}
