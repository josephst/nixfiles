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
    home-manager = {
      enable = lib.mkEnableOption "home-manager";
      home = lib.mkOption {
        default = ../../../home;
        type = lib.types.path;
      };
    };
  };

  config = {
    home-manager = lib.mkIf cfg.home-manager.enable {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = { inherit inputs; };
      backupFileExtension = ".backup-pre-hm";
      # sharedModules = builtins.attrValues outputs.homeManagerModules; # TODO: not sure what this does
      users."${cfg.user}" = import cfg.home-manager.home;
    };
    users = {
      defaultUserShell = pkgs.fish;
      users.${cfg.user} = {
        isNormalUser = true;
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
