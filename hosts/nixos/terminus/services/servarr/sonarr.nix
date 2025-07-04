{ config, ... }:
let
  inherit (config.networking) domain;
in
{
  services.sonarr = {
    enable = true;
    group = "media";
  };

  # TODO: remove when Sonarr updated to use dotnet 8
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-6.0.428"
  ];

  services.caddy.virtualHosts."sonarr.${domain}" = {
    extraConfig = ''
      reverse_proxy http://localhost:8989
    '';
    useACMEHost = domain;
  };
}
