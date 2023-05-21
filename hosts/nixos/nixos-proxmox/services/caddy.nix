{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.caddy = {
    enable = true;
    globalConfig = ''
      servers {
        metrics
      }
    '';
    virtualHosts = {
      "${hostName}.taildb4c.ts.net" = {
        extraConfig = ''
          encode gzip
          file_server
          respond "Hello, world! (Tailscale)"
        '';
        # uses caddy's builtin tailscale integration for https certificate
      };
      "${fqdn}" = {
        extraConfig = ''
          encode gzip
          file_server
          respond "Hello, world! (NOT Tailscale)"
        '';
        useACMEHost = fqdn;
      };
    };
    # service-specific config for Caddy reverse-proxying located
    # in each service file (ie sabnzbd.nix, etc.)
  };
}
