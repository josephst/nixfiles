# modules/darwin/myConfig/user.nix
{ config, pkgs, ... }:

let
  cfg = config.myConfig.user;
  inherit (config.myConfig) keys;
in
{
  imports = [
    ../../common/myConfig/user.nix
  ];

  config = {
    system.primaryUser = cfg.username;
    users = {
      users.${cfg.username} = {
        home = "/Users/${cfg.username}";
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.${cfg.username};
        packages = [ pkgs.home-manager ];
      };
    };
  };
}
