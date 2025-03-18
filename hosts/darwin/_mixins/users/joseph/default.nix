{ ... }:
let
  keys = import ../../../../../keys;
in
{
  users.users.joseph = {
    description = "Joseph Stahl";
    openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
  };
}
