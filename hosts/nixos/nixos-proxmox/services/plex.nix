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
      ReadWritePaths = cfg.dataDir;
      ProtectHome = "read-only";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies= [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      # RestrictNamespaces = true; # can't use because of need for FHS env
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
    };
  };
}
