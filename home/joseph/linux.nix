{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && osConfig.hostSpec.role != "installer") {
    # On macOS GitHub authentication is provided by the 1Password CLI plugin.
    age.secrets."gh/hosts.yml" = {
      file = ./secrets/gh_hosts.yml.age;
      path = "${config.xdg.configHome}/gh/hosts.yml";
    };
  };
}
