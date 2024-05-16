{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.open-webui;
in
{
  meta.maintainers = [ lib.maintainers.josephst ];

  options = {
    services.open-webui = {
      enable = lib.mkEnableOption ''
        Open WebUI is an extensible, feature-rich, and user-friendly self-hosted WebUI designed to operate entirely offline.
        It supports various LLM runners, including Ollama and OpenAI-compatible APIs.

        Requires Ollama to be available, either installed locally (`services.ollama.enable = true`)
        or with an accessible API endpoint.
      '';

      package = lib.mkPackageOption pkgs "open-webui" { };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "The host/domain under which Open WebUI is reachable";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8082; # 8080 conflicts with other services
        description = "The port for the Open WebUI service";
      };

      ollamaUrl = lib.mkOption {
        type = with lib; types.nullOr types.str;
        default = null;
        description = "URL to an Ollama instance";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open firewall port for Open WebUI";
      };

      # CORS?
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.open-webui = {
      description = "Open WebUI service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "open-webui";
        Group = "open-webui";
        DynamicUser = true;
        Restart = "on-failure";
        Type = "exec";

        StateDirectory = "open-webui";
        WorkingDirectory = "/var/lib/open-webui";

        ExecStartPre = [
          # ignore error if dirs already exist
          # "-${pkgs.coreutils}/bin/mkdir data"
          # "-${pkgs.coreutils}/bin/mkdir data/litellm"
          "${pkgs.coreutils}/bin/install -D ${cfg.package}/lib/backend/data/config.json /var/lib/open-webui/data"
          "${pkgs.coreutils}/bin/install -D ${cfg.package}/lib/backend/data/litellm/config.yaml /var/lib/open-webui/data/litellm"
        ];
        ExecStart = "${cfg.package}/bin/open-webui --port ${toString cfg.port} --host ${cfg.host} --forwarded-allow-ips '*'";
      };

      environment = {
        DATA_DIR = "/var/lib/open-webui/data";
        ENV = "prod";
        FRONTEND_BUILD_DIR = "${cfg.package}/lib/build";
        HOME = "/var/lib/open-webui";
        OLLAMA_BASE_URL = cfg.ollamaUrl;
        LITELLM_LOCAL_MODEL_COST_MAP = "True";

        HF_HOME = "/var/lib/open-webui/hf-home";
        TRANSFORMERS_CACHE = "/var/lib/open-webui/transformers-cache";
        SENTENCE_TRANSFORMERS_HOME = "/var/lib/open-webui/sentence_transformers_home";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
