{ config, options, ... }:
{
  # new Agenix configuration which is *user-specific* (DISTINCT from the system Agenix config)
  age = {
    identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ] ++ options.age.identityPaths.default;
  };
}
