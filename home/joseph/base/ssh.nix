{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
let
  inherit (osConfig.myConfig) keys;
  username = "joseph";
  hostname = osConfig.networking.hostName;

  # identity = a user-specific and host-specific key (one identity per user per machine)
  # userAllKeys = all keys registered to a user (across all machines)
  userAllKeys =
    if keys != null && lib.hasAttr username keys.users then lib.getAttr username keys.users else null;
  userHostSpecificKey =
    if userAllKeys != null && lib.hasAttr hostname userAllKeys then
      lib.getAttr hostname userAllKeys
    else
      null;
  identityFile = ".ssh/identity.pub";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = lib.optional pkgs.stdenv.isDarwin "${config.home.homeDirectory}/.orbstack/ssh/config";
    matchBlocks = {
      "*" = {
        # defaults, from home-manager module
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        # additional options
        identityFile =
          lib.mkIf config.home.file.${identityFile}.enable
            "${config.home.file.${identityFile}.source}";
        extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      };
      "terminus terminus.josephstahl.com" = {
        hostname = "terminus";
        forwardAgent = true;
        identitiesOnly = true;
        identityFile =
          lib.mkIf config.home.file.${identityFile}.enable
            "${config.home.file.${identityFile}.source}";
      };
      "github.com" = {
        user = "git";
        identityFile = lib.mkIf config.home.file.${identityFile}.enable [
          "${config.home.file.${identityFile}.source}"
          "~/.ssh/identity" # only having pubkey here can cause issues
        ];
        identitiesOnly = lib.mkIf (userHostSpecificKey != null) true;
      };
    };
  };

  home.file.${identityFile} = {
    enable = userHostSpecificKey != null;
    text = userHostSpecificKey;
  };
}
