{
  config,
  ...
}:
let
  hostSpec = config.hostSpec;
in
{

  config = {
    networking = {
      computerName = hostSpec.hostName;
    };
  };
}
