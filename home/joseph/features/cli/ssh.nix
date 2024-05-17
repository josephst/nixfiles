{ pkgs, lib, osConfig, ... }:
# TODO: try and centralize this section/ refactor into a config.key... module
# public key is written to disk, private key stays in password manager
let
  identityEnabled = osConfig.myconfig.sshUserKey != null;
  identityFile = "${pkgs.writeText "sshPubKey" (if identityEnabled
                                                then osConfig.myconfig.sshUserKey
                                                else "")}";
in
{
  programs.ssh = {
    enable = true;
    includes = lib.optional (pkgs.stdenv.isDarwin) "~/.orbstack/ssh/config";
    matchBlocks =
      {
        "*" = {
          inherit identityFile;
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
