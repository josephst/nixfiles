{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.sonarr = {
    enable = true;
    group = "media";
    package = pkgs.unstable.sonarr;
  };

  services.caddy.virtualHosts."sonarr.${fqdn}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8989
    '';
    useACMEHost = fqdn;
  };

  # Ensure that sonarr waits for the downloads and media directories to be
  # available.
  systemd.services.sonarr = {
    wantedBy = ["multi-user.target"];
    after = [
      "network.target"
      "mnt-nas.automount"
    ];
  };
}
