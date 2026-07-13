let
  keys = import ../keys;

  # let user=joseph edit and rekey as needed
  all = builtins.attrValues keys.hostKeys ++ builtins.attrValues keys.ageRecipients.joseph;
in
{
  "ghToken.age".publicKeys = all;
  "users/joseph.age".publicKeys = all;
}
