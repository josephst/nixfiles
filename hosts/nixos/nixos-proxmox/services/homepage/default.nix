{
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  bolt = pkgs.fetchFromGitHub {
    owner = "tbolt";
    repo = "boltcss";
    rev = "de77c4bcb08e581e4b49d3e489382e8ee9b503b9";
    sha256 = "sha256-mTKPsXRWm74+l99cyy4AttRsnenOvMnl728A61Jv9SY=";
  };
  webRoot = pkgs.buildEnv {
    name = "webroot";
    paths = [
      (pkgs.writeTextDir "index.html" (builtins.readFile(./index.html)))
      (pkgs.writeTextDir "bolt.css" (builtins.readFile("${bolt}/bolt.css")))
    ];
  };
in {
  services.caddy.virtualHosts."home.${fqdn}" = {
    extraConfig = ''
      encode gzip
      file_server
      root * ${webRoot}
    '';
    useACMEHost = fqdn;
  };
}
