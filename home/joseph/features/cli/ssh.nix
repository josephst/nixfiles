{
  pkgs,
  lib,
  config,
  ...
}:
let
  identityEnabled = config.myconfig.userSshKeys.identityFileText != null;
  identityFile = lib.optionalString identityEnabled "${pkgs.writeText "sshPubKey" (
    config.myconfig.userSshKeys.identityFileText
  )}";
in
{
  programs.ssh = {
    enable = true;
    includes = lib.optional (pkgs.stdenv.isDarwin) "~/.orbstack/ssh/config";
    matchBlocks = {
      "*" = {
        identityFile = lib.mkIf identityEnabled identityFile;
        extraOptions = lib.optionalAttrs (pkgs.stdenv.isDarwin) {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
      "nixos nixos.josephstahl.com" = {
        hostname = "nixos";
        user = "joseph";
        forwardAgent = true;
        identityFile = lib.mkIf identityEnabled identityFile;
      };
      "proxmox proxmox.josephstahl.com" = {
        hostname = "proxmox";
        user = "root";
        forwardAgent = true;
        identityFile = lib.mkIf identityEnabled identityFile;
      };
    };
  };
}
