let
  keys = import ../../../keys;
in
{
  "ghToken.age".publicKeys = builtins.attrValues keys.hosts;
}