_: {
  # secrets specific to this device

  age.secrets.netdata_nixos_claim = {
    file = ./netdata_nixos_claim.age;
  };

  age.secrets.resticb2env = {
    # contents:
    # RCLONE_REMOTE=<rclone path>
    # AWS_ACCESS_KEY_ID=
    # AWS_SECRET_ACCESS_KEY=
    # HC_UUID=<uuid for healthchecks>
    file = ./restic/b2.env.age;
  };
  age.secrets.resticb2bucketname.file = ./restic/b2bucketname.age;
  age.secrets.restic-localmaintenance-env.file = ./restic/restic-server-maintenance.env.age;

  age.secrets.rcloneConf = {
    # contents: rclone.conf file contents with NAS and B2 access info
    file = ./rclone.conf.age;
  };

  age.secrets.restic-localstorage-pass = {
    # contents: password for restic repo
    file = ./restic/localstorage.pass.age;
    owner = "restic";
  };

  age.secrets.restic-systembackup-env = {
    # contents: HC_UUID
    file = ./restic/systembackup.env.age;
  };

  age.secrets.zwave-js-keys = {
    file = ./zwave-js-keys.json.age;
    # TODO: use systemd's LoadCredential so that this file doesn't need to be globally readable
    mode = "774"; # needs to be readable by user zwave-js, but this is created by systemd's DynamicUser
  };
}
