{
  config,
  lib,
  ...
}:
let
  cfg = config.myConfig;
  # Common SSH known hosts for popular Git services
  commonKnownHosts = {
    "github.com" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    "gitlab.com" = {
      hostNames = [ "gitlab.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    };

    "git.sr.ht" = {
      hostNames = [ "git.sr.ht" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    };
  };
in
{
  config = {
    programs.ssh = {
      knownHosts =
        commonKnownHosts
        // lib.optionals (cfg.keys != null) lib.mapAttrs (hostname: _value: {
          publicKey = cfg.keys.hosts.${hostname};
          hostNames =
            [ hostname ]
            ++ lib.optional (config.hostSpec.tailnet != null) "${hostname}.${config.hostSpec.tailnet}"
            ++ lib.optional (hostname == config.networking.hostName) "localhost";
        }) cfg.keys.hosts;
    };
  };
}
