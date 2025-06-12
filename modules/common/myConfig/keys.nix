{
  lib,
  config,
  ...
}:
let
  inherit (config.hostSpec) username;
  cfg = config.myConfig;
in
{
  options.myConfig = with lib; {
    keys =
      with lib;
      mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              hosts = mkOption {
                type = types.attrsOf types.str;
                default = { };
                description = "SSH host keys for machines";
              };
              users = mkOption {
                type = types.attrsOf (types.attrsOf types.str);
                default = { };
                description = "SSH user keys per machine";
              };
              signing = mkOption {
                type = types.attrsOf types.str;
                default = { };
                description = "Git commit signing keys per user";
              };
            };
          }
        );
        default = null;
        description = "SSH and signing keys for this system and its users";
      };
  };

  config = lib.mkIf (cfg.keys != null) {
    users.users.${username}.openssh.authorizedKeys.keys =
      lib.optionals (builtins.hasAttr username cfg.keys.users)
        (builtins.attrValues cfg.keys.users.${username});
  };
}