{
  pkgs,
  config,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.coredns = {
    enable = true;
    config = ''
      . {
        log . {
          class denial error
        }
        cache
        local
        prometheus
        forward . 1.1.1.1 1.0.0.1
      }

      ts.net {
        forward . 100.100.100.100
        errors
      }

      taildbd4c.ts.net {
        forward . 100.100.100.100
        errors
      }

      nixos.josephstahl.com {
        # file ${./nixos.josephstahl.com.zone}
        template IN A  {
            answer "{{ .Name }} 0 IN A 192.168.1.10"
        }
      }

      proxmox.josephstahl.com {
        template IN A {
          answer "{{ .Name }} 0 IN A 192.168.1.7"
        }
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
