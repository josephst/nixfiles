{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.recyclarr;
  format = pkgs.formats.yaml { };

  # taken from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/home-automation/home-assistant.nix, by mweinelt
  renderYAMLFile =
    fn: yaml:
    pkgs.runCommand fn
      {
        preferLocalBuilds = true;
      }
      ''
        cp ${format.generate fn yaml} $out
        sed -i -e "s/'\!\([a-z_]\+\) \(.*\)'/\!\1 \2/;s/^\!\!/\!/;" $out
      '';
in
{
  disabledModules = [ "services/misc/recyclarr.nix" ]; # override the upstream module

  options.services.recyclarr = {
    enable = lib.mkEnableOption "recyclarr service";

    package = lib.mkPackageOption pkgs "recyclarr" { };

    configuration = lib.mkOption {
      inherit (format) type;
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
      '';
    };

    secretsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Absolute path to a YAML file containing secrets for recyclarr. This is loaded as a systemd credential.";
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
        configFile = renderYAMLFile "recyclarr.yaml" cfg.configuration;
      in
      {
        description = "Recyclarr Service";
        after = [
          "sonarr.service"
          "radarr.service"
        ];
        wants = [
          "sonarr.service"
          "radarr.service"
        ];

        path = [
          pkgs.git
        ];

        script = ''
          if [ -f "$CREDENTIALS_DIRECTORY/secretsYaml" ]; then
            ln -sf "$CREDENTIALS_DIRECTORY/secretsYaml" "$STATE_DIRECTORY/secrets.yml"
          fi

          ${lib.getExe cfg.package} ${cfg.command} --app-data $STATE_DIRECTORY --config ${configFile}
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "recyclarr";
          DynamicUser = true;
          LoadCredential = lib.optionalString (cfg.secretsFile != null) "secretsYaml:${cfg.secretsFile}";
          StateDirectory = "recyclarr";
          RuntimeDirectory = "recyclarr";
          LogsDirectory = "recyclarr";

          # Hardening
          # ProtectSystem = "strict"; # implied by DynamicUser
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          LockPersonality = true;
          # MemoryDenyWriteExecute = true; # breaks dotnet
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          # NoNewPrivileges = true; # implied
          # RestrictSUIDSGID = true; # implied
          # RemoveIPC = true; # implied
          CapabilityBoundingSet = "";

          # Networking
          PrivateNetwork = false;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
        };
      };

    systemd.timers.recyclarr = {
      description = "Recyclarr Timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
