{
  config,
  ...
}:
let
  inherit (config) hostSpec;
in
{

  config = {
    networking = {
      computerName = hostSpec.hostName;
    };
  };
}
