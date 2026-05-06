{
  config,
  lib,
  ...
}:
let
  repositorySecretFile = ../secrets/restic/paperless-repository.age;
  passwordSecretFile = ../secrets/restic/paperless-password.age;
  secretsAvailable =
    builtins.pathExists repositorySecretFile && builtins.pathExists passwordSecretFile;

  credentialDir = "/run/credentials/restic-backups-paperless.service";
in
{
  age.secrets = lib.mkIf secretsAvailable {
    "restic/paperless-repository".file = repositorySecretFile;
    "restic/paperless-password".file = passwordSecretFile;
  };

  services.restic.backups.paperless = lib.mkIf secretsAvailable {
    initialize = true;
    repositoryFile = "${credentialDir}/repository";
    passwordFile = "${credentialDir}/password";

    paths = [
      "/var/lib/paperless/export"
    ];

    extraBackupArgs = [
      "--cleanup-cache"
      "--tag paperless"
      "--tag export"
    ];

    pruneOpts = [
      "--keep-daily 30"
      "--keep-weekly 12"
      "--keep-monthly 12"
      "--keep-yearly 5"
    ];

    checkOpts = [
      "--read-data-subset 1G"
      "--with-cache"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 02:30:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  systemd.services.restic-backups-paperless = lib.mkIf secretsAvailable {
    serviceConfig.LoadCredential = [
      "repository:${config.age.secrets."restic/paperless-repository".path}"
      "password:${config.age.secrets."restic/paperless-password".path}"
    ];
    unitConfig.ConditionPathIsDirectory = "/var/lib/paperless/export";
  };

  warnings = lib.optional (!secretsAvailable) ''
    anacreon Paperless Restic backup is not enabled yet: add
    hosts/nixos/anacreon/secrets/restic/paperless-repository.age and
    hosts/nixos/anacreon/secrets/restic/paperless-password.age.
  '';
}
