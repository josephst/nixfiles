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
  scanConfig = pkgs.writeText "brscan-skey-scantofile.config" ''
    source ${packagePath}/scantofile.config
    resolution=${toString cfg.scanResolution}
    size=${lib.escapeShellArg cfg.scanSize}
  '';
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
      example = "/var/lib/paperless/consume";
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

    scanResolution = lib.mkOption {
      type = lib.types.ints.positive;
      default = 300;
      example = 600;
      description = ''
        Resolution in dots per inch for the Scan to File action.
        Choose a resolution supported by the scanner.
      '';
    };

    scanSize = lib.mkOption {
      type = lib.types.strMatching "(MAX|A3|A4|A5|A6|Letter|Legal|[0-9]+(\\.[0-9]+)?x[0-9]+(\\.[0-9]+)?)";
      default = "Letter";
      example = "210x297";
      description = ''
        Paper size for the Scan to File action. Use a vendor paper-size name
        or a widthxheight size in millimetres.
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

    # The scan directory is the final file directory. When it is Paperless's
    # consumption directory, Paperless owns its mode and ownership; the
    # private staging directory remains inside StateDirectory.
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
          "BRSCAN_SKEY_STAGING_DIR=/var/lib/brscan-skey/staging"
          "HOME=/var/lib/brscan-skey"
          "SANE_CONFIG_DIR=/etc/sane-config"
          "LD_LIBRARY_PATH=/etc/sane-libs"
          # Vendor scripts invoke the bundled skey-scanimage by absolute
          # path; PATH supplies their shell utilities, not SANE's scanimage.
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
          # The vendor script checks its per-user config first. Mount the
          # generated settings there to override the packaged resolution.
          "${scanConfig}:/var/lib/brscan-skey/.brscan-skey/scantofile.config"
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
          # brscan5 initializes libusb even for network scanners. Its udev
          # monitor needs Netlink; blocking it makes libusb_init fail and
          # the vendor driver crash during scanner discovery.
          "AF_NETLINK"
          "AF_UNIX"
        ];
      };
    };
  };
}
