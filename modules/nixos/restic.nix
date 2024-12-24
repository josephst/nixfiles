{ config, lib, pkgs, ... }:
let
  # get all configs where healthchecks are enabled
  cfg = lib.filterAttrs (_: value: value.healthchecksUrl != null || value.healthchecksFile != null) config.services.restic.backups;
  # true if cfg contains any configured healthchecksUrl or healtchecksFile
  healthchecksEnabled = cfg != { };

  # capitalize the variable name and replace hyphens with underscores
  # (hyphens not allowed in bash variable names)
  urls = lib.mapAttrs' (n: v: lib.attrsets.nameValuePair (lib.toUpper (builtins.replaceStrings ["-"] ["_"] n)) (if v.healthchecksUrl == null then builtins.readFile v.healthchecksFile else v.healthchecksUrl)) cfg;
  healthcheckEnvFile = pkgs.writeText "healthchecks.env" (lib.generators.toKeyValue {} urls);
in
{
  # extend the restic module to also support reporting successes to healthchecks.io
  options.services.restic.backups = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({... }: {
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
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Path to a file containing the healthchecks.io URL.
            A URL set in `healthchecksUrl` takes precedence.
          '';
          example = "/var/run/agenix/healthchecksUrl";
        };
      };
    }));
  };

  config = lib.mkIf healthchecksEnabled {
    systemd.services."healthcheck-ping@" = {
      description = "Pings healthcheck (%i)";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = healthcheckEnvFile;
      };
      scriptArgs = "%i";
      script = ''
        set -x # for debugging

        IFS=':' read -r name action <<< "$1"
        name="''${name^^}" # capitalize
        name="''${name//-/_}" # replace hyphens with underscores
        url="''${!name}" # urls are loaded fron EnvironmentFile

        if [ "$action" = "success" ]; then
          ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url"
        else
          ${lib.getExe pkgs.curl} -fsS -m 10 --retry 5 "$url/$action"
        fi
      '';
    };
  };
}


# systemd.services = lib.mkMerge [
#   (lib.mapAttrs'
#     (name: backup:
#       lib.nameValuePair "restic-backups-${name}" {
#         wants = [ "healthcheck-ping@${name}:start.service" ];
#         onSuccess = [ "healthcheck-ping@${name}:success.service" ];
#         onFailure = [ "healthcheck-ping@${name}:failure.service" ];
#       }
#     ) cfg)
