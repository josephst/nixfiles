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
      description = "List of remotes to sync (must be listed in `~/.config/rclone/rclone.conf`)";
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "onedrive" ];
    };

    local = lib.mkOption {
      description = "Local folder to sync remotes to (will delete files not in remote)";
      type = lib.types.str;
      default = "/home/${config.home.username}/rclone";
    };

    extraArgs = lib.mkOption {
      description = "Additional rclone arguments";
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--dry-run" ];
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
              [ "${pkgs.rclone}/bin/rclone sync '${remote}:' '${cfg.local}/${remote}'" ]
              ++ [ (lib.escapeShellArgs cfg.extraArgs) ]
            );
          };
          Install.WantedBy = [ "default.target" ];
        };
      }) cfg.remotes
    );

    systemd.user.timers = builtins.listToAttrs (
      map (remote: {
        name = "rclone-${remote}";
        value = {
          Unit = {
            Description = "rclone sync timer (${remote})";
          };
          Timer = {
            OnStartupSec = "1h";
            OnUnitInactiveSec = "4h"; # runs every 4 hours after last sync finishes
            RandomizedDelaySec = "1h"; # +/- 1hr
          };
          Install.WantedBy = [ "timers.target" ];
        };
      }) cfg.remotes
    );
  };
}
