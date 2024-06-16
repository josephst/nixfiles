{ config, ... }:
let
  inherit (config.networking) fqdn;
in
{
  security.acme = {
    acceptTerms = true;
    # TODO: hide email?
    defaults.email = "josephst18+acme@outlook.com";
    defaults.dnsResolver = "1.1.1.1:53"; # can't be local DNS since nixos.josephstahl.com resolves to local IP on LAN
    certs."${fqdn}" = {
      domain = "*.${fqdn}";
      extraDomainNames = [ fqdn ];
      dnsProvider = "cloudflare";
      # group = config.services.caddy.group;
      credentialsFile = config.age.secrets.dnsApiToken.path;
      dnsPropagationCheck = true;
    };
  };
}
