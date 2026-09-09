{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = config.hostSpec.username;
in
{
  environment.systemPackages = [ pkgs.moshi-hook ];

  # The common user module enables lingering, so default.target is reached at
  # boot without waiting for an interactive login.
  home-manager.users.${username}.systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi agent hook daemon";
      Documentation = "https://getmoshi.app/docs/install-moshi-hook";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.moshi-hook} serve";
      Environment = "PATH=${
        lib.makeBinPath [
          pkgs.git
          pkgs.herdr
          pkgs.openssh
          pkgs.tmux
          pkgs.zellij
        ]
      }";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
