{ config, lib, ... }:
let
  cfg = config.myconfig.userSshKeys;
in
{
  imports = [ ];

  options.myconfig.userSshKeys = {
    identityFileText = lib.mkOption {
      description = "Public SSH key to use (to represent the user for ie authenticating to remote servers)";
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    # note: this is configured per-user in ssh settings
    gitSigningKey = lib.mkOption {
      description = "Public SSH key corresponding to key used to sign Git commits";
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf (cfg.gitSigningKey != null) {
    # Mark this SSH key as valid for signing git commits
    programs.git = lib.mkIf (cfg.gitSigningKey != null && config.programs.git.enable) {
      signing.key = cfg.gitSigningKey;
      extraConfig.gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
    home.file = lib.mkIf (cfg.gitSigningKey != null) {
      ".ssh/allowed_signers".text = "${config.programs.git.userEmail} ${cfg.gitSigningKey}";
    };
  };
}
