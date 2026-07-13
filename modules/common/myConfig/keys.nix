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
              ageRecipients = mkOption {
                type = types.attrsOf (types.attrsOf types.str);
                default = { };
                description = "Agenix recipients per user; these do not grant SSH login";
              };
              hostKeys = mkOption {
                type = types.attrsOf types.str;
                default = { };
                description = "SSH host keys for machines";
              };
              loginKeys = mkOption {
                type = types.attrsOf (types.attrsOf types.str);
                default = { };
                description = "SSH login keys per user and machine";
              };
              signingKeys = mkOption {
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
      lib.optionals (builtins.hasAttr username cfg.keys.loginKeys)
        (builtins.attrValues cfg.keys.loginKeys.${username});
  };
}
