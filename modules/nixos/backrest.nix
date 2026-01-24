{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.backrest;
  bindSpec = "${cfg.bindAddress}:${toString cfg.port}";
  resticUsers = lib.unique (
    lib.mapAttrsToList (_: v: v.user or "root") (config.services.restic.backups or { })
  );
  resticUserDefault =
    if resticUsers == [ ] then
      "root"
    else if lib.length resticUsers == 1 then
      builtins.head resticUsers
    else
      "root";
in
{
  options.services.backrest = {
    enable = lib.mkEnableOption "Backrest web UI and restic orchestrator";

    package = lib.mkPackageOption pkgs "backrest" { };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Address for Backrest to bind to. 0.0.0.0 for all interfaces.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9898;
      description = "Port for the Backrest web UI.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the Backrest web UI.";
    };

    readWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths Backrest may read and write (for restic repositories or cache).";
      example = [
        "/storage"
      ];
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = resticUserDefault;
      description = "User account under which Backrest runs. Defaults to the restic backup user when configured.";
    };

  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == "backrest") {
      backrest = {
        isSystemUser = true;
        description = "Backrest service user";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.backrest = {
      description = "Backrest web UI";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        User = cfg.user;
        Restart = "on-failure";
        RestartSec = 5;

        Environment = [
          "BACKREST_PORT=${bindSpec}"
          "BACKREST_CONFIG=%S/backrest/config.json"
          "BACKREST_DATA=%S/backrest"
          "XDG_CACHE_HOME=%C/backrest"
          "TMPDIR=%T"
        ];

        StateDirectory = "backrest";
        CacheDirectory = "backrest";
        RuntimeDirectory = "backrest";
        WorkingDirectory = "%S/backrest";
        ReadWritePaths = cfg.readWritePaths;

        UMask = "0077";

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        LockPersonality = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
    };
  };
}
