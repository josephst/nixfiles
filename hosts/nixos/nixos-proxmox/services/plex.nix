{
  pkgs,
  config,
  ...
}: let
  cfg = config.services.plex;
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.plex = {
    enable = true;
    group = "media";
    package = pkgs.unstable.plex;
  };

  services.caddy.virtualHosts."plex.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:32400
      encode gzip
    '';
    useACMEHost = fqdn;
  };

  # Ensure that plex waits for the downloads and media directories to be
  # available.
  systemd.services.plex = {
    after = [
      "network.target"
      "mnt-nas.automount"
    ];
    serviceConfig = {
      TimeoutStopSec = 5;
      # hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      DevicePolicy = "closed";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = cfg.dataDir;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies= [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };
}
