{ lib
, pkgs
, username
, ...
}:
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};

  users.users.${username} = {
    packages = [ pkgs.home-manager ];
  };

  home-manager.users.${username} = import ../../../../home;
}
