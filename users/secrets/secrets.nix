let
  keys = import ../../keys;

  # include all `joseph` keys to allow me to rekey secrets with my user key
  allKeys = builtins.attrValues keys.users.joseph ++ builtins.attrValues keys.hosts;
in
{
  "users/joseph.age".publicKeys = allKeys;
}