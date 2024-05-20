{
  pkgs,
  ...
}:
let
  keys = import ../keys;
in
{
  users.users = {
    root = {
      shell = pkgs.bashInteractive;

      # let me log in as root with SSH
      openssh.authorizedKeys.keys = builtins.attrValues keys.users.joseph;
    };
  };
}
