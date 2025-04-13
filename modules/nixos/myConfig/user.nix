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
      type = lib.types.nullOr lib.types.path;
      description = "password file for agenix";
    };
  };

  config = {
    age.secrets.password = lib.mkIf (cfg.passwordFile != null) {
      file = cfg.passwordFile;
    };

    users = {
      defaultUserShell = pkgs.fish;
      users.${cfg.username} = {
        isNormalUser = true;
        hashedPasswordFile = lib.mkIf (cfg.passwordFile != null) config.age.secrets.password.path;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = lib.optional (keys.users ? cfg.username) (builtins.attrValues keys.users.${cfg.username});
        packages = [ pkgs.home-manager ];
      };
      users.root = {
        hashedPassword = lib.mkDefault null;
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
      };
    };
  };
}
