{ inputs, outputs, config, lib, ... }:

let
  cfg = config.myConfig.user;
  inherit (config.myConfig) keys;
in
{
  options.myConfig.user = {
    username = lib.mkOption {
      default = "joseph";
      type = lib.types.str;
      description = "The username of the user to create.";
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
  };
}
