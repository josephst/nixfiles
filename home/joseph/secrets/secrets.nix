let
  keys = import ../../../keys;
in
{
  "gh_hosts.yml.age".publicKeys = keys.recipientGroups.joseph;
  "1pass.env.age".publicKeys = keys.recipientGroups.joseph;
  "1pass.age".publicKeys = keys.recipientGroups.joseph;
}
