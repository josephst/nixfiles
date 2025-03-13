{ username, lib, ... }:
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};
}
