{
  lib,
  config,
  ...
}:
let
  cfg = config.myConfig;
in
{
  options.myConfig.nixAccessTokensFile = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = null;
    description = ''
      Agenix source containing a complete nix.conf fragment with
      access-tokens entries.
    '';
  };

  config = lib.mkIf (cfg.nixAccessTokensFile != null) {
    age.secrets.nix-access-tokens = {
      file = cfg.nixAccessTokensFile;
      mode = "0440";
    };
    nix.extraOptions = ''
      !include ${config.age.secrets.nix-access-tokens.path}
    '';
  };
}
