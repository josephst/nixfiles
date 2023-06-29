{pkgs, ...}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
  };
}
