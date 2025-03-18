{ ... }:
let
  keys = import ../../../../../keys;
in
{
  age.secrets.joseph.file = ../../../../../secrets/users/joseph.age;

  users.users.joseph = {
    description = "Joseph Stahl";
    openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
  };
}
