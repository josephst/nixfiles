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
  configPath = "${stateDir}/openclaw.json";
  secretsPath = "${stateDir}/openclaw.secrets.json";
  jq = lib.getExe pkgs.jq;
  chmod = lib.getExe' pkgs.coreutils "chmod";
  mkdir = lib.getExe' pkgs.coreutils "mkdir";
  mv = lib.getExe' pkgs.coreutils "mv";
  readlink = lib.getExe' pkgs.coreutils "readlink";

  mergeSecretsScript = pkgs.writeShellScript "openclaw-merge-secrets.sh" ''
    set -euo pipefail

    config_path="${configPath}"
    secrets_path="${secretsPath}"

    if [ ! -f "$secrets_path" ]; then
      echo "OpenClaw secrets file missing: $secrets_path" >&2
      echo "Create JSON overlays there for botToken/gateway token/API keys." >&2
      exit 1
    fi

    if [ -L "$config_path" ]; then
      base_config="$("${readlink}" -f "$config_path")"
    else
      base_config="$config_path"
    fi

    tmp_config="${configPath}.tmp"

    ${jq} -s '
      def rmerge(a; b):
        reduce (b | keys_unsorted[]) as $key (a;
          .[$key] = (
            if (a[$key] | type) == "object" and (b[$key] | type) == "object"
            then rmerge(a[$key]; b[$key])
            else b[$key]
            end
          )
        );
      rmerge(.[0]; .[1])
    ' "$base_config" "$secrets_path" > "$tmp_config"

    "${mv}" "$tmp_config" "$config_path"
    "${chmod}" 600 "$config_path"
  '';
in
{
  imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

  config = lib.mkIf isTerminus {
    programs.openclaw = {
      enable = true;
      package = inputs.nix-openclaw.packages.${pkgs.system}.openclaw;

      # Keep only non-secret config in Nix; secrets are merged at runtime.
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
          auth.mode = "token";
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

        skills.entries."nano-banana-pro" = { };
      };
    };

    # One-time migration helper: extract current secrets from an unmanaged config.
    home.activation.openclawSecretsBootstrap = lib.hm.dag.entryBefore [ "openclawConfigFiles" ] ''
      set -euo pipefail

      secrets_path="${secretsPath}"
      config_path="${configPath}"

      if [ -e "$secrets_path" ]; then
        exit 0
      fi

      if [ ! -f "$config_path" ] || [ -L "$config_path" ]; then
        exit 0
      fi

      run --quiet ${mkdir} -p "$(dirname "$secrets_path")"

      tmp_secrets="${secretsPath}.tmp"
      ${jq} '
        {
          channels: {
            telegram: {
              botToken: .channels.telegram.botToken
            }
          },
          gateway: {
            auth: {
              token: .gateway.auth.token
            }
          },
          skills: {
            entries: {
              "nano-banana-pro": {
                apiKey: .skills.entries["nano-banana-pro"].apiKey
              }
            }
          }
        } | del(.. | nulls)
      ' "$config_path" > "$tmp_secrets"

      run --quiet ${chmod} 600 "$tmp_secrets"
      run --quiet ${mv} "$tmp_secrets" "$secrets_path"
    '';

    # Merge unmanaged secrets into generated config just before gateway start.
    systemd.user.services.openclaw-gateway.Service.ExecStartPre = lib.mkBefore [
      "${mergeSecretsScript}"
    ];
  };
}
