let
  keys = import ../../../keys;
in
{
  "gh_hosts.yml.age".publicKeys = builtins.attrValues keys.users.joseph;
  "aider.conf.yml.age".publicKeys = builtins.attrValues keys.users.joseph;
}
