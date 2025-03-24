{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.user;
  inherit (config.myConfig) keys;
in
{
  imports = [
    ../../common/myConfig/user.nix
  ];

  options.myConfig.user = {
    passwordFile = lib.mkOption {
      default = null;
      type = lib.types.path;
      description = "password file for agenix";
    };
  };

  config = {
    age.secrets.password.file = cfg.passwordFile;

    users = {
      defaultUserShell = pkgs.fish;
      users.${cfg.username} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.password.path;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.${cfg.username};
        packages = [ pkgs.home-manager ];
      };
      users.root = {
        hashedPassword = null;
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
      };
    };
  };
}
