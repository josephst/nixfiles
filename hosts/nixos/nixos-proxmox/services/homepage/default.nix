{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  webRoot = pkgs.buildEnv {
    name = "webroot";
    paths = [
      (pkgs.writeTextDir "index.html" (builtins.readFile ./index.html))
      (pkgs.writeTextDir "new.min.css" (builtins.readFile ./new.min.css))
    ];
  };
in {
  services.caddy.virtualHosts."${fqdn}" = {
    extraConfig = ''
      encode gzip
      file_server
      root * ${webRoot}
    '';
    useACMEHost = fqdn;
  };
}
