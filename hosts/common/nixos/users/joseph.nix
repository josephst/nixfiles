{
  pkgs,
  config,
  ...
}:
let
  keys = import ../../../../keys;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  age.secrets.joseph.file = ./secrets/users/joseph.age;

  users.users = {
    joseph = {
      description = "Joseph Stahl";
      openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
      shell = pkgs.fish;
      hashedPasswordFile = config.age.secrets.joseph.path;
      isNormalUser = true;
      createHome = true;
      extraGroups =
        [
          "wheel" # Enable ‘sudo’ for the user.
        ]
        ++ ifTheyExist [
          "media"
        ];
      linger = true; # linger w/ systemd (starts user units at bootup, rather than login)
      packages = [
        pkgs.home-manager
      ];
    };
  };

  home-manager.users.joseph = import ../../../../home/joseph;
  home-manager.backupFileExtension = ".backup-pre-hm";
}
