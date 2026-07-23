{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.backrest;
  formattedBindAddress =
    if lib.hasInfix ":" cfg.bindAddress && !lib.hasPrefix "[" cfg.bindAddress then
      "[${cfg.bindAddress}]"
    else
      cfg.bindAddress;
  bindSpec = "${formattedBindAddress}:${toString cfg.port}";
in
{
  options.services.backrest = {
    enable = lib.mkEnableOption "Backrest web UI and restic orchestrator";

    package = lib.mkPackageOption pkgs "backrest" { };
    resticPackage = lib.mkPackageOption pkgs "restic" { };

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
      description = ''
        Additional paths made writable inside the Backrest mount namespace.
        This does not grant Unix ownership, group, mode, or ACL permissions.
      '';
      example = [
        "/storage"
      ];
    };

    readOnlyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Additional paths explicitly exposed read-only to Backrest. This does
        not grant Unix ownership, group, mode, or ACL permissions.
      '';
      example = [
        "/srv/exports"
      ];
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "backrest";
      description = "User account under which Backrest runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "backrest";
      description = "Group under which Backrest runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.bindAddress != "";
        message = "services.backrest.bindAddress must not be empty";
      }
    ];

    users.groups = lib.mkIf (cfg.group == "backrest") {
      backrest = { };
    };

    users.users = lib.mkIf (cfg.user == "backrest") {
      backrest = {
        isSystemUser = true;
        description = "Backrest service user";
        inherit (cfg) group;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # StateDirectory= and friends ensure the top-level directories have the
    # configured ownership. Recursively repair existing contents as well when
    # migrating Backrest from another service user, while preserving modes.
    systemd.tmpfiles.rules = [
      "Z %S/backrest - ${cfg.user} ${cfg.group} - -"
      "Z %C/backrest - ${cfg.user} ${cfg.group} - -"
      "Z %t/backrest - ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.backrest = {
      description = "Backrest web UI";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = 5;

        Environment = [
          "BACKREST_PORT=${bindSpec}"
          "BACKREST_CONFIG=%S/backrest/config.json"
          "BACKREST_DATA=%S/backrest"
          "BACKREST_RESTIC_COMMAND=${lib.getExe cfg.resticPackage}"
          "XDG_CACHE_HOME=%C/backrest"
          "TMPDIR=%T"
        ];

        StateDirectory = "backrest";
        CacheDirectory = "backrest";
        RuntimeDirectory = "backrest";
        WorkingDirectory = "%S/backrest";
        StateDirectoryMode = "0700";
        CacheDirectoryMode = "0700";
        RuntimeDirectoryMode = "0700";
        ReadOnlyPaths = cfg.readOnlyPaths;
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
