{ lib
, pkgs
, username
, ...
}:
{
  imports = [ ./root ] ++ lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};

  environment.localBinInPath = true;
  users.users.${username} = {
    extraGroups = [
      "input"
      "users"
      "wheel"
    ];
    homeMode = "0755";
    isNormalUser = true;
    packages = [ pkgs.home-manager ];
    shell = pkgs.fish;
  };

  home-manager.users.${username} = import ../../../../home;
}
