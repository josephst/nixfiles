{
  config,
  ...
}:
let
  inherit (config) hostSpec;
in
{
  # The Tailscale app and macOS own DNS/resolver integration. nix-darwin only
  # supplies the stable local and Bonjour-visible computer name here.
  config = {
    networking = {
      computerName = hostSpec.hostName;
    };
  };
}
