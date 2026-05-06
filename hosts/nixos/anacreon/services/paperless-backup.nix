{
  config,
  lib,
  ...
}:
let
  repositorySecretFile = ../secrets/restic/paperless-repository.age;
  passwordSecretFile = ../secrets/restic/paperless-password.age;
  environmentSecretFile = ../secrets/restic/paperless.env.age;
  secretsAvailable =
    builtins.pathExists repositorySecretFile
    && builtins.pathExists passwordSecretFile
    && builtins.pathExists environmentSecretFile;

  credentialDir = "/run/credentials/restic-backups-paperless.service";
in
{
  age.secrets = lib.mkIf secretsAvailable {
    "restic/paperless-repository".file = repositorySecretFile;
    "restic/paperless-password".file = passwordSecretFile;
    "restic/paperless.env".file = environmentSecretFile;
  };

  services.restic.backups.paperless = lib.mkIf secretsAvailable {
    initialize = true;
    repositoryFile = "${credentialDir}/repository";
    passwordFile = "${credentialDir}/password";
    environmentFile = config.age.secrets."restic/paperless.env".path;

    paths = [
      "/var/lib/paperless/export"
    ];

    extraBackupArgs = [
      "--cleanup-cache"
      "--tag paperless"
      "--tag export"
    ];

    # TODO: remove this when `terminus` is back online;
    # only one machine running prune & forget commands is necessary
    pruneOpts = [
      "--keep-daily 30"
      "--keep-weekly 52"
      "--keep-monthly 24"
      "--keep-yearly 10"
      "--keep-tag forever"
    ];
    checkOpts = [
      "--read-data-subset 500M"
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
    hosts/nixos/anacreon/secrets/restic/paperless-password.age and
    hosts/nixos/anacreon/secrets/restic/paperless.env.age.
  '';
}
