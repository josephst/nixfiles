{ pkgs, ... }:
{
  imports = [
    ./apps
    ./features
  ];

  environment.systemPackages = [];
}
