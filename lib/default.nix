# from https://github.com/wimpysworld/nix-config (MIT License)
{
  inputs,
  outputs,
  ...
}:
let
  helpers = import ./helpers.nix { inherit inputs outputs; };
in
{
  inherit (helpers)
    mkDarwin
    mkNixos
    forAllSystems
    forLinuxSystems
    ;
}
