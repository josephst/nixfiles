{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
  };
}
