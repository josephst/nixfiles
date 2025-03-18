_:
let
  keys = import ../../../../../keys;
in
{
  users.users.root = {
    hashedPassword = null;
    openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph; # admin
  };
}
