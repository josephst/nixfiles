{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  isTerminus = (osConfig ? hostSpec) && (osConfig.hostSpec.hostName or null) == "terminus";
  stateDir = "${config.home.homeDirectory}/.openclaw";
  openclawEnvFile = ../secrets/openclaw.env.age;
  hasOpenclawEnvFile = builtins.pathExists openclawEnvFile;
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  config = lib.mkIf isTerminus (
    lib.mkMerge [
      {
        programs.openclaw = {
          enable = true;
          # `openclaw` is a batteries-included buildEnv that re-exports a large
          # toolchain under /bin. That collides with the tools this profile
          # already installs through home.packages and programs.*.enable.
          package = inputs.nix-openclaw.packages.${pkgs.system}.openclaw-gateway;

          config = {
            agents.defaults = {
              compaction.mode = "safeguard";
              maxConcurrent = 4;
              model = {
                fallbacks = [
                  "google/gemini-3-flash-preview"
                  "google/gemini-3-pro-preview"
                  "openai-codex/gpt-5.2"
                ];
                primary = "openai-codex/gpt-5.3-codex";
              };
              models = {
                "google/gemini-3-flash-preview" = { };
                "google/gemini-3-pro-preview" = { };
                "openai-codex/gpt-5.2" = { };
                "openai-codex/gpt-5.3-codex" = { };
              };
              subagents.maxConcurrent = 8;
              workspace = "${stateDir}/workspace";
            };

            auth.profiles = {
              "google:default" = {
                mode = "api_key";
                provider = "google";
              };
              "openai-codex:default" = {
                mode = "oauth";
                provider = "openai-codex";
              };
            };

            browser = {
              enabled = true;
              executablePath = "/run/current-system/sw/bin/google-chrome";
              headless = true;
            };

            channels.telegram = {
              botToken = {
                id = "OPENCLAW_TELEGRAM_BOT_TOKEN";
                provider = "default";
                source = "env";
              };
              dmPolicy = "pairing";
              enabled = true;
              groupPolicy = "allowlist";
              streamMode = "partial";
            };

            commands = {
              native = "auto";
              nativeSkills = "auto";
              restart = true;
            };

            env.shellEnv.enabled = false;

            gateway = {
              auth = {
                mode = "token";
                # TODO: switch this to a SecretRef after nix-openclaw accepts
                # gateway.auth.token as a typed SecretRef, not just a string.
                token = "\${OPENCLAW_GATEWAY_TOKEN}";
              };
              bind = "loopback";
              mode = "local";
              nodes.denyCommands = [
                "camera.snap"
                "camera.clip"
                "screen.record"
                "calendar.add"
                "contacts.add"
                "reminders.add"
              ];
              port = 18789;
              tailscale = {
                mode = "off";
                resetOnExit = false;
              };
              trustedProxies = [
                "::1"
                "127.0.0.1"
              ];
            };

            hooks.internal = {
              enabled = true;
              entries = {
                "boot-md".enabled = true;
                "bootstrap-extra-files".enabled = true;
                "command-logger".enabled = true;
                "session-memory".enabled = true;
              };
            };

            messages.ackReactionScope = "group-mentions";

            plugins.entries.telegram.enabled = true;

            secrets.providers.default = {
              source = "env";
            };

            skills.entries."nano-banana-pro".apiKey = {
              id = "NANO_BANANA_API_KEY";
              provider = "default";
              source = "env";
            };
          };
        };
      }

      (lib.mkIf hasOpenclawEnvFile {
        age.secrets."openclaw.env" = {
          file = openclawEnvFile;
        };

        systemd.user.services.openclaw-gateway.Service.EnvironmentFile = [
          config.age.secrets."openclaw.env".path
        ];
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
