{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  age.secrets.googleDomainsApiToken = {
    file = ../../../../secrets/googleDomainsApiToken.age;
  };

  security.acme = {
    acceptTerms = true;
    # TODO: hide email?
    defaults.email = "josephst18+acme@outlook.com";
    certs."${fqdn}" = {
      domain = "*.${fqdn}";
      extraDomainNames = [fqdn];
      dnsProvider = "googledomains";
      dnsResolver = "1.1.1.1:53"; # can't be local DNS since nixos.josephstahl.com resolves to local IP on LAN
      # group = config.services.caddy.group;
      credentialsFile = config.age.secrets.googleDomainsApiToken.path;
      dnsPropagationCheck = true;
    };
  };
}
