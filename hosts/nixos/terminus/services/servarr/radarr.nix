{ pkgs, config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.radarr = {
    enable = true;
    group = "media";
    package = pkgs.unstable.radarr;
  };

  services.caddy.virtualHosts."radarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:7878
    '';
    useACMEHost = domain;
  };

  # Ensure that radarr waits for the downloads and media directories to be
  # available.
  systemd.services.radarr = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "mnt-nas.automount"
    ];
  };
}
