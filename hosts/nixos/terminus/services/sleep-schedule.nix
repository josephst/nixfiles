{
  pkgs,
  ...
}:
{
  systemd.services.suspend-at-night = {
    description = "Suspend at midnight";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl suspend";
    };
  };

  systemd.timers.suspend-at-night = {
    description = "Suspend at midnight";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Unit = "suspend-at-night.service";
    };
  };

  systemd.services.wake-during-daytime = {
    description = "Wake at 10:00";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };

  systemd.timers.wake-during-daytime = {
    description = "Wake at 10:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 10:00:00";
      Persistent = true;
      Unit = "wake-during-daytime.service";
      WakeSystem = true;
    };
  };
}
