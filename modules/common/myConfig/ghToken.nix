{
  lib,
  config,
  ...
}:
let
  cfg = config.myConfig;
in
{
  options.myConfig = with lib; {
    ghToken = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to GitHub token secret (avoid rate-limiting by GitHub)";
    };
  };

  config = lib.mkIf (cfg.ghToken != null) {
    age = {
      secrets.ghToken = {
        file = cfg.ghToken;
        mode = "0440";
      };
    };
    nix.extraOptions = ''
      !include ${config.age.secrets.ghToken.path}
    '';
  };
}