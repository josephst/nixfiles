{
  pkgs,
  lib,
  config,
  ...
}:
let
  identityEnabled = config.myconfig.userSshKeys.identityFileText != null;
  identityFile = "~/.ssh/identity.pub";
in
{
  programs.ssh = {
    enable = true;
    includes = lib.optional pkgs.stdenv.isDarwin "~/.orbstack/ssh/config";
    matchBlocks = {
      "*" = {
        identityFile = lib.mkIf identityEnabled identityFile;
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
      "terminus terminus.josephstahl.com" = {
        hostname = "terminus";
        user = "joseph";
        forwardAgent = true;
        identityFile = lib.mkIf identityEnabled identityFile;
        # extraOptions = {
        #   RequestTTY = "yes";
        # };
      };
      "proxmox proxmox.josephstahl.com" = {
        hostname = "proxmox";
        user = "root";
        forwardAgent = true;
        identityFile = lib.mkIf identityEnabled identityFile;
      };
      "github.com" = {
        user = "git";
        identityFile = [
          lib.mkIf identityEnabled identityFile
          "~/.ssh/identity" # only having pubkey here can cause issues
        ];
        identitiesOnly = lib.mkIf identityEnabled true;
      };
    };
  };

  home.file.".ssh/identity.pub" = {
    enable = identityEnabled;
    text = config.myconfig.userSshKeys.identityFileText;
  };
}
