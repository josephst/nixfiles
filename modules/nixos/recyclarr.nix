{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.services.recyclarr;
  format = pkgs.formats.yaml { };
  templates = pkgs.runCommand "recyclarr-merged-templates" { } ''
    mkdir $out
    cp --no-preserve=mode -r "${inputs.recyclarr-templates}"/radarr/includes $out
    cp --no-preserve=mode -r "${inputs.recyclarr-templates}"/sonarr/includes $out
  '';
in
{
  options.services.recyclarr = {
    enable = lib.mkEnableOption "recyclarr service";

    package = lib.mkPackageOption pkgs "recyclarr" { };

    configuration = lib.mkOption {
      type = format.type;
      default = { };
      example = {
        sonarr = {
          main = {
            base_url = "http://localhost:8989";
            api_key = "!secret sonarr_api_key";

            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;
          };
        };
        radarr = {
          main = {
            base_url = "http://localhost:7878";
            api_key = "!secret radarr_api_key";

            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;
          };
        };
      };
      description = ''
        Recyclarr YAML configuration as a Nix attribute set.

        For detailed configuration options and examples, see the
        [official configuration reference](https://recyclarr.dev/wiki/yaml/config-reference/).

        To avoid permission issues, secrets should be provided via systemd's credential mechanism:

        ```nix
        systemd.services.recyclarr.serviceConfig.LoadCredential = [
          "secretsYaml:''${config.sops.secrets.secretsYaml.path}"
        ];
        ```
      '';
    };

    secretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to secrets.yaml file.";
      default = null;
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "When to run recyclarr in systemd calendar format.";
    };

    command = lib.mkOption {
      type = lib.types.str;
      default = "sync";
      description = "The recyclarr command to run (e.g., sync).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.recyclarr =
      let
        configFile = format.generate "recyclarr.yaml" cfg.configuration;
      in
      {
        description = "Recyclarr Service";

        PreStart = ''
          ln -sf $CREDENTIALS_DIRECTORY/secretsYaml $STATE_DIRECTORY/secrets.yaml
          ln -sf "${templates}"/includes "$STATE_DIRECTORY/includes"
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "recyclarr";
          DynamicUser = true;
          LoadCredential = lib.optionalString (cfg.secretsFile != null) "secretsYaml:${cfg.secretsFile}";
          StateDirectory = "recyclarr";
          RuntimeDirectory = "recyclarr";
          ExecStart = "${lib.getExe cfg.package} ${cfg.command} --app-data $STATE_DIRECTORY --config ${configFile}";

          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;

          PrivateNetwork = false;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          NoNewPrivileges = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;

          CapabilityBoundingSet = "";

          LockPersonality = true;
          RestrictRealtime = true;
        };
      };

    systemd.timers.recyclarr = {
      description = "Recyclarr Timer";
      wantedBy = [ "timers.target" ];
      partOf = [ "recyclarr.service" ];

      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
