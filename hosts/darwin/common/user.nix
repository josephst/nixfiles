# modules/darwin/myConfig/user.nix
{ config, ... }:

let
  hostSpec = config.hostSpec;
in
{
  system.primaryUser = hostSpec.username;
  users = {
    users.${hostSpec.username} = {
      home = hostSpec.home;
    };
  };
}
