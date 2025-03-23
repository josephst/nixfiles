{ inputs, config, lib, pkgs, ... }:

let
  cfg = config.myConfig;
  keys = import ../../../keys;
in
{
  options.myConfig = {
    user = lib.mkOption {
      default = "joseph";
      type = lib.types.str;
    };
    password = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
    home-manager = {
      enable = lib.mkEnableOption "home-manager" // { default = true; };
      home = lib.mkOption {
        default = ../../../home;
        type = lib.types.path;
      };
    };
  };

  config = {
    assertions = [{
      assertion = cfg.password != null;
      message = "You must provide a password file.";
    }];

    age.secrets.password.file = cfg.password;

    home-manager = lib.mkIf cfg.home-manager.enable {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = {
        inherit inputs;
        username = cfg.user;
        hostname = cfg.hostname;
      };
      backupFileExtension = ".backup-pre-hm";
      # sharedModules = builtins.attrValues outputs.homeManagerModules; # TODO: not sure what this does
      users."${cfg.user}" = import cfg.home-manager.home;
    };
    users = {
      defaultUserShell = pkgs.fish;
      users.${cfg.user} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.password.path;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
      };
      users.root = {
        hashedPassword = null;
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
      };
    };
  };
}
