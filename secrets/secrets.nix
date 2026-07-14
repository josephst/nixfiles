let
  keys = import ../keys;
in
{
  "ghToken.age".publicKeys = keys.recipientGroups.fleet;
  "users/joseph.age".publicKeys = keys.recipientGroups.fleet;
}
