{config, ...}:
let
  keys = import ../../../../../keys;
in {
  age.secrets.joseph.file = ../../../../../secrets/users/joseph.age;

  users.users.joseph = {
    description = "Joseph Stahl";
    hashedPasswordFile = config.age.secrets.joseph.path;
    openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
  };

  systemd.tmpfiles.rules = [
    "d /home/joseph/.ssh 0700 joseph users -"
    "f /home/joseph/.ssh/id_ed25519 0600 joseph users -"
    "f /home/joseph/.ssh/id_ed25519.pub 0600 joseph users -"
  ];
}
