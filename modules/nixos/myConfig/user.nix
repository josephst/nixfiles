{
  config,
  lib,
  pkgs,
  ...
}:

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
    shell = lib.mkOption {
      default = pkgs.fish;
      type = lib.types.package;
      description = "The shell to use for the user.";
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
        inherit (cfg) shell;
        hashedPasswordFile = lib.mkIf (cfg.passwordFile != null) config.age.secrets.password.path;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = lib.optionals (builtins.hasAttr cfg.username keys.users) (
          builtins.attrValues keys.users.${cfg.username}
        );
        packages = [ pkgs.home-manager ];
      };
      users.root = {
        hashedPassword = lib.mkDefault null;
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
      };
    };
  };
}
