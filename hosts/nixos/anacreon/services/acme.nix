{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  age.secrets.dnsApiToken = {
    file = ../secrets/cloudflare-dns.age;
  };

  security.acme = {
    acceptTerms = true;
    defaults.dnsResolver = "1.1.1.1:53"; # can't be local DNS since anacreon.josephstahl.com resolves to local IP on LAN
    certs."${domain}" = {
      domain = "*.${config.networking.hostName}.${domain}";
      extraDomainNames = [ "${config.networking.hostName}.${domain}" ];
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CF_DNS_API_TOKEN_FILE" = config.age.secrets.dnsApiToken.path;
      };
      dnsPropagationCheck = true;
    };
  };
}
