{
  config,
  lib,
  ...
}:
let
  secretFile = ../secrets/tailscale-authkey.age;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  age.secrets.tailscale-authkey = lib.mkIf hasSecretFile {
    file = secretFile;
  };

  services.tailscale.authKeyFile = lib.mkIf hasSecretFile config.age.secrets.tailscale-authkey.path;

  warnings = lib.optional (!hasSecretFile) ''
    anacreon tailscale autoconnect is not enabled yet: add hosts/nixos/anacreon/secrets/tailscale-authkey.age
    and populate keys.hosts.anacreon before rekeying.
  '';
}
