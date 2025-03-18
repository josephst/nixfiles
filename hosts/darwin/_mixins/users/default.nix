{ lib
, pkgs
, username
, ...
}:
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};

  users.users.${username} = {
    packages = [ pkgs.home-manager ];
    home = "/Users/${username}";
  };

  home-manager.users.${username} = import ../../../../home;
}
