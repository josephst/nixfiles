{
  config,
  lib,
  osConfig,
  ...
}:
let
  isTerminus = (osConfig ? hostSpec) && (osConfig.hostSpec.hostName or null) == "terminus";
  stateDir = "${config.home.homeDirectory}/.openclaw";
  workspaceDir = "${stateDir}/workspace";
  openclawEnvFile = ../secrets/openclaw.env.age;
  hasOpenclawEnvFile = builtins.pathExists openclawEnvFile;
  gatewayPort = 18789;
  containerImage = "ghcr.io/openclaw/openclaw:latest";
  containerStateDir = "/home/node/.openclaw";
in
{
  # TODO: create a new Openclaw user and move this to that user (and use oci-container), instead of running
  # as joseph and using home-manager
  config = lib.mkIf isTerminus (
    lib.mkMerge [
      {
        services.podman = {
          enable = true;
          containers.openclaw-gateway = {
            autoUpdate = "registry";
            description = "OpenClaw gateway OCI container";
            environment = {
              HOME = "/home/node";
              OPENCLAW_CONFIG_PATH = "${containerStateDir}/openclaw.json";
              OPENCLAW_STATE_DIR = containerStateDir;
            };
            extraConfig = {
              Service = {
                RestartSec = "5s";
                TimeoutStartSec = 900;
              };
              Unit = {
                After = [ "network-online.target" ];
                Wants = [ "network-online.target" ];
              };
            };
            extraPodmanArgs = [
              "--pull=missing"
              "--network=host"
            ];
            image = containerImage;
            ports = [ "127.0.0.1:${toString gatewayPort}:${toString gatewayPort}" ];
            userNS = "keep-id";
            volumes = [
              "${stateDir}:${containerStateDir}"
              "${config.age.secrets."openclaw.env".path}:/home/node/.openclaw/.env:ro"
            ];
          };
        };

        systemd.user.tmpfiles.rules = [
          "d ${stateDir} 0700 ${config.home.username} users - -"
          "d ${workspaceDir} 0700 ${config.home.username} users - -"
        ];
      }

      (lib.mkIf hasOpenclawEnvFile {
        age.secrets."openclaw.env" = {
          file = openclawEnvFile;
        };
      })

      {
        warnings = lib.optional (!hasOpenclawEnvFile) ''
          OpenClaw expects env-backed secrets. Create home/joseph/secrets/openclaw.env.age
          from home/joseph/secrets/openclaw.env.example and re-run home-manager.
        '';
      }
    ]
  );
}
