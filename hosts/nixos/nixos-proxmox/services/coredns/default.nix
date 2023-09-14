{
  pkgs,
  config,
  ...
}: let
  fqdn = config.networking.fqdn;
in {
  services.coredns = {
    enable = true;
    config = ''
      . {
        bind 192.168.1.10
        log . {
          class denial error
        }
        cache
        local
        prometheus
        forward . 1.1.1.1 1.0.0.1
      }

      ts.net {
        bind 192.168.1.10
        forward . 100.100.100.100
        errors
      }

      taildbd4c.ts.net {
        bind 192.168.1.10
        forward . 100.100.100.100
        errors
      }

      nixos.josephstahl.com {
        bind 192.168.1.10
        # file ${./nixos.josephstahl.com.zone}
        template IN A  {
            answer "{{ .Name }} 0 IN A 192.168.1.10"
        }
      }

      nas.josephstahl.com {
        bind 192.168.1.10
        template IN A {
          answer "{{ .Name }} 0 IN A 192.168.1.12"
        }
      }

      proxmox.josephstahl.com {
        bind 192.168.1.10
        template IN A {
          answer "{{ .Name }} 0 IN A 192.168.1.7"
        }
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
