{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.brscan-skey;
  brscan5Path = "${pkgs.brscan5}/opt/brother/scanner/brscan5";
  packagePath = "${cfg.package}/opt/brother/scanner/brscan-skey";
in
{
  meta.maintainers = [ lib.maintainers.josephst ];

  options.services.brscan-skey = {
    enable = lib.mkEnableOption "the Brother scan-key tool";

    package = lib.mkPackageOption pkgs "brscan-skey" { };

    scanDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/brscan-skey-scans";
      description = ''
        Directory in which the Brother Scan to File action writes scans.
        The directory is created with the scanner service user as owner and
        the scanner service group as group. Keep this outside /home because
        the service protects home directories with ProtectHome.
      '';
      example = "/storage/homes/public/scans";
    };

    scanDirectoryMode = lib.mkOption {
      type = lib.types.strMatching "[0-7]{4}";
      default = "0750";
      description = ''
        Mode for the scan directory. The default permits the scanner service
        group to read and traverse it, without making scans world-readable.

        When the scan directory is also services.paperless.consumptionDir,
        Paperless manages the directory's mode and ownership instead.
      '';
    };

    scanFileUmask = lib.mkOption {
      type = lib.types.strMatching "[0-7]{4}";
      default = "0027";
      description = ''
        Process umask applied to generated scans. The default keeps files
        private to the scanner user and group. Use 0022 when another service
        must read scans through a world-accessible directory.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "brscan-skey";
      description = "User account under which the scan-key tool runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "brscan-skey";
      description = "Group used for scan-directory access.";
    };

    privateDevices = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Hide host device nodes from the scan-key service. This is appropriate
        for network-connected scanners; set to false when the scanner is
        connected over USB.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.scanDirectory != "/";
        message = "services.brscan-skey.scanDirectory must not be the filesystem root";
      }
    ];

    users.groups = lib.mkIf (cfg.group == "brscan-skey") {
      brscan-skey = { };
    };

    users.users = lib.mkIf (cfg.user == "brscan-skey") {
      brscan-skey = {
        description = "Brother scan-key tool service user";
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    # Paperless owns its consumption directory when the two options point at
    # the same path. Otherwise, retain a self-contained default for users of
    # this module without Paperless.
    systemd.tmpfiles.settings."10-brscan-skey" =
      lib.mkIf
        (!config.services.paperless.enable || cfg.scanDirectory != config.services.paperless.consumptionDir)
        {
          ${cfg.scanDirectory}.d = {
            inherit (cfg) group;
            mode = cfg.scanDirectoryMode;
            inherit (cfg) user;
          };
        };

    systemd.services.brscan-skey = {
      description = "Brother scan-key tool";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      unitConfig.RequiresMountsFor = [ cfg.scanDirectory ];

      serviceConfig = {
        Type = "forking";
        ExecStart = "${packagePath}/brscan-skey";
        ExecStop = "${packagePath}/brscan-skey --terminate";
        Group = cfg.group;
        User = cfg.user;

        Environment = [
          "BRSCAN_SKEY_SCAN_DIR=${cfg.scanDirectory}"
          "HOME=/var/lib/brscan-skey"
          "SANE_CONFIG_DIR=/etc/sane-config"
          "LD_LIBRARY_PATH=/etc/sane-libs"
          "PATH=${
            lib.makeBinPath [
              pkgs.bash
              pkgs.coreutils
              pkgs.curl
              pkgs.gnugrep
            ]
          }"
        ];

        StateDirectory = "brscan-skey";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/brscan-skey";
        ReadWritePaths = [ cfg.scanDirectory ];
        UMask = cfg.scanFileUmask;

        # The vendor binaries require their historical paths. Expose only the
        # package's scan-key subtree, read-only, inside this service namespace;
        # no /opt files are created on the host.
        BindReadOnlyPaths = [
          "${packagePath}:/opt/brother/scanner/brscan-skey"
          "${packagePath}:/etc/opt/brother/scanner/brscan-skey"
        ]
        ++ lib.optional config.hardware.sane.brscan5.enable "${brscan5Path}:/opt/brother/scanner/brscan5";

        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        PrivateDevices = cfg.privateDevices;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
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
