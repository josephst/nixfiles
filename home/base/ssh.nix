{ pkgs
, config
, lib
, username
, ...
}:
let
  keys = import ../../keys;

  identityFileText =
    if lib.hasAttr username keys.users.${username} then lib.getAttr username keys.users.${username} else null;
  identityFile = ".ssh/identity.pub";
in
{
  programs.ssh = {
    enable = true;
    includes = lib.optional pkgs.stdenv.isDarwin "${config.home.homeDirectory}/.orbstack/ssh/config";
    matchBlocks = {
      "*" = {
        identityFile = lib.mkIf (identityFileText != null) config.home.file.${identityFile}.source;
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
      "terminus terminus.josephstahl.com" = {
        hostname = "terminus";
        forwardAgent = true;
        identityFile = lib.mkIf (identityFileText != null) config.home.file.${identityFile}.source;
      };
      "github.com" = {
        user = "git";
        identityFile = lib.mkIf (identityFileText != null) [
          identityFile
          "~/.ssh/identity" # only having pubkey here can cause issues
        ];
        identitiesOnly = lib.mkIf (identityFileText != null) true;
      };
    };
  };

  home.file.${identityFile} = {
    enable = identityFileText != null;
    text = identityFileText;
  };
}
