# modules/darwin/myConfig/user.nix
{ config, pkgs, ... }:

let
  cfg = config.myConfig.user;
  keys = config.myConfig.keys;
in
{
  imports = [
    ../../common/myConfig/user.nix
  ];

  config = {
    users = {
      users.${cfg.username} = {
        home = "/Users/${cfg.username}";
        openssh.authorizedKeys.keys = builtins.attrValues keys.users.${cfg.username};
        packages = [ pkgs.home-manager ];
      };
    };
  };
}
