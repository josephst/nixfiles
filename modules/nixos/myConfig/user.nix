{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.myConfig.user;
  keys = config.myConfig.keys;
in
{
  options.myConfig.user = {
    username = lib.mkOption {
      default = "joseph";
      type = lib.types.str;
      description = "The username of the user to create.";
    };
    passwordFile = lib.mkOption {
      default = null;
      type = lib.types.path;
      description = "password file for agenix";
    };
    home-manager = {
      enable = lib.mkEnableOption "home-manager" // { default = true; };
      home = lib.mkOption {
        default = ../../../home/${cfg.username};
        type = lib.types.path;
      };
    };
  };

  config = {
    age.secrets.password.file = cfg.passwordFile;

    home-manager = lib.mkIf cfg.home-manager.enable {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = {
        inherit inputs;
      };
      backupFileExtension = ".backup-pre-hm";
      sharedModules = (builtins.attrValues outputs.homeManagerModules) ++ [
        {
          myHomeConfig.keys = keys;
          myHomeConfig.username = cfg.username;
        }
      ];
      users."${cfg.username}" = import cfg.home-manager.home;
    };

    users = {
      defaultUserShell = pkgs.fish;
      users.${cfg.username} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.password.path;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.${cfg.username};
      };
      users.root = {
        hashedPassword = null;
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
      };
    };
  };
}
