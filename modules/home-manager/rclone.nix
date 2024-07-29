{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myconfig.rclone;
in
{
  imports = [ ];

  options.myconfig.rclone = {
    remotes = lib.mkOption {
      description = "List of remotes to clone (must be listed in `~/.config/rclone/rclone.conf`)";
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "onedrive" ];
    };

    local = lib.mkOption {
      description = "Local folder to copy remotes to";
      type = lib.types.str;
      default = "/home/${config.home.username}/rclone";
    };

    dryRun = lib.mkOption {
      description = "Rclone dry run";
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (((lib.length cfg.remotes) > 0) && pkgs.stdenv.hostPlatform.isLinux) {
    systemd.user.tmpfiles.rules = map (remote: "D '${cfg.local}/${remote}' 0700 - - -") cfg.remotes;

    systemd.user.services = builtins.listToAttrs (
      map (remote: {
        name = "rclone-${remote}";
        value = {
          Unit = {
            Description = "rclone sync service (${remote})";
          };
          Service = {
            CPUSchedulingPolicy = "idle";
            IOSchedulingClass = "idle";
            Type = "oneshot";
            ExecStart = lib.concatStringsSep " " (
              [ "${pkgs.rclone}/bin/rclone copy '${remote}:' '${cfg.local}/${remote}'" ]
              ++ (lib.optional cfg.dryRun "--dry-run")
            );
          };
        };
      }) cfg.remotes
    );
  };
}
