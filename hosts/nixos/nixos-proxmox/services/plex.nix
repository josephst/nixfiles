{
  pkgs,
  config,
  ...
}: let
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
    '';
    useACMEHost = fqdn;
  };

  # Ensure that plex waits for the downloads and media directories to be
  # available.
  systemd.services.plex = {
    wantedBy = ["multi-user.target"];
    after = [
      "network.target"
      "mnt-nas.automount"
    ];
  };
}
