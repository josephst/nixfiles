let
  keys = import ../../../keys;
in
{
  "gh_hosts.yml.age".publicKeys = builtins.attrValues keys.users.joseph;
  "1pass.env.age".publicKeys = builtins.attrValues keys.users.joseph;
  "1pass.age".publicKeys = builtins.attrValues keys.users.joseph;
}
