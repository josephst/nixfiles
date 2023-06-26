{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  age.secrets.dnsApiToken = {
    file = ../../../../secrets/dnsApiToken.age;
  };

  security.acme = {
    acceptTerms = true;
    # TODO: hide email?
    defaults.email = "josephst18+acme@outlook.com"; # can't be local DNS since nixos.josephstahl.com resolves to local IP on LAN
    defaults.dnsResolver = "1.1.1.1:53";
    certs."${fqdn}" = {
      domain = "*.${fqdn}";
      extraDomainNames = [fqdn];
      dnsProvider = "cloudflare";
      # group = config.services.caddy.group;
      credentialsFile = config.age.secrets.dnsApiToken.path;
      dnsPropagationCheck = true;
    };
  };
}
