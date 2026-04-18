{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets.cloudflare-dns.file = ../secrets/cloudflare-dns.age;

  security.acme = {
    acceptTerms = true;
    defaults.email = "grilles_cachets7a@icloud.com";
    defaults.dnsResolver = "1.1.1.1:53";
    certs."${domain}" = {
      domain = "*.${domain}";
      extraDomainNames = [ domain ];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.cloudflare-dns.path;
      dnsPropagationCheck = true;
    };
  };
}
