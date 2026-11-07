{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets.dnsApiToken = {
    file = ../secrets/dnsApiToken.age;
  };

  security.acme = {
    acceptTerms = true;
    defaults.dnsResolver = "1.1.1.1:53"; # can't be local DNS since homelab.josephstahl.com resolves to local IP on LAN
    certs."${domain}" = {
      domain = "*.${domain}";
      extraDomainNames = [ domain ];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.dnsApiToken.path;
      dnsPropagationCheck = true;
    };
  };
}
