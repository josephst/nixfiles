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
    if keys != null && lib.hasAttr username keys.loginKeys then
      lib.getAttr username keys.loginKeys
    else
      null;
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
    settings = {
      "*" = {
        # defaults, from home-manager module
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        # additional options
        IdentityFile = lib.mkIf config.home.file.${identityFile}.enable "~/${identityFile}";
        IdentityAgent = lib.mkIf pkgs.stdenv.isDarwin ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };
      "terminus terminus.josephstahl.com" = {
        HostName = "terminus";
        ForwardAgent = true;
        IdentitiesOnly = true;
        IdentityFile = lib.mkIf config.home.file.${identityFile}.enable "~/${identityFile}";
      };
      "anacreon anacreon.josephstahl.com" = {
        HostName = "anacreon";
        ForwardAgent = true;
        IdentitiesOnly = true;
        IdentityFile = lib.mkIf config.home.file.${identityFile}.enable "~/${identityFile}";
      };
      "github.com" = {
        User = "git";
        IdentityFile = lib.mkIf config.home.file.${identityFile}.enable [
          "~/${identityFile}"
          "~/.ssh/identity" # only having pubkey here can cause issues
        ];
        IdentitiesOnly = lib.mkIf (userHostSpecificKey != null) true;
      };
    };
  };

  home.file.${identityFile} = {
    enable = userHostSpecificKey != null;
    text = userHostSpecificKey;
  };
}
