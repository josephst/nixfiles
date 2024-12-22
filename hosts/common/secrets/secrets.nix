let
  keys = import ../../../keys;

  # let user=joseph edit and rekey as needed
  all = builtins.attrValues keys.hosts ++ builtins.attrValues keys.users.joseph;
in
{
  "ghToken.age".publicKeys = all;
}
