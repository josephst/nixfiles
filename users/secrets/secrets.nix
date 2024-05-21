let
  keys = import ../../keys;

  # include all `joseph` keys to allow me to rekey secrets with my user key
  allKeys = keys.users;
in
{
  "users/joseph.age".publicKeys = builtins.attrValues allKeys.joseph;
}