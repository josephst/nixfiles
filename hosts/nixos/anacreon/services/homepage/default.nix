{
  pkgs,
  lib,
  config,
  ...
}:
let
  fs = lib.fileset;
  siteHost = "anacreon.${config.hostSpec.tailnet}";
  tailscaleServe = lib.getExe config.services.tailscale.package;
  homepage-assets = pkgs.stdenv.mkDerivation {
    name = "anacreon-homepage-assets";
    src = fs.toSource {
      root = ./.;
      fileset = fs.unions [
        ./index.html
        ./new.min.css
      ];
    };
    installPhase = ''
      mkdir -p $out
      cp index.html new.min.css $out/
    '';
  };
in
{
  services = {
    caddy.virtualHosts.":8080" = {
      listenAddresses = [ "127.0.0.1" ];
      extraConfig = ''
        root * ${pkgs.compressDrvWeb homepage-assets { }}
        file_server {
          precompressed br gzip
        }
      '';
    };
    caddy.virtualHosts."${siteHost}" = {
      extraConfig = ''
        root * ${pkgs.compressDrvWeb homepage-assets { }}
        file_server {
          precompressed br gzip
        }
      '';
    };
  };

  # Work around tailscale/tailscale#18381 by using the CLI directly instead of
  # services.tailscale.serve.services, which goes through `serve set-config`.
  systemd.services.anacreon-home-tailscale-serve = {
    description = "Tailscale Serve proxy for Anacreon homepage";
    after = [
      "caddy.service"
      "tailscaled.service"
      "tailscaled-autoconnect.service"
      "tailscaled-set.service"
    ];
    wants = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.concatStringsSep " " [
        tailscaleServe
        "serve"
        "--service=srv:home"
        "--https=443"
        "http://127.0.0.1:8080"
      ];
      ExecStop = "${tailscaleServe} serve clear srv:home";
    };
  };
}
