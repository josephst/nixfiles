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
      log
      cache
      loadbalance
      local
      forward . tls://1.1.1.1 tls://1.0.0.1 {
        tls_servername cloudflare-dns.com
      }
    }

    nixos.josephstahl.com {
      file ${./nixos.josephstahl.com.zone}
      # template IN A  {
      #     answer "{{ .Name }} 0 IN A 127.0.0.1"
      # }
    }

    proxmox.josephstahl.com {
      template IN A {
        answer "{{ .Name }} 0 IN A 192.168.1.7"
      }
    }
    '';
  };
}
