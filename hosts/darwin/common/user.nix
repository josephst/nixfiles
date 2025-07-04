# modules/darwin/myConfig/user.nix
{ config, ... }:

let
  inherit (config) hostSpec;
in
{
  system.primaryUser = hostSpec.username;
  users = {
    users.${hostSpec.username} = {
      inherit (hostSpec) home;
    };
  };
}
