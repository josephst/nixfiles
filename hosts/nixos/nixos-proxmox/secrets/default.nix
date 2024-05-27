{ ... }:
{
  # secrets specific to this device
  age.secrets.smb = {
    file = ./smb.age;
    owner = "root";
    group = "root";
  };
  age.secrets.dnsApiToken = {
    file = ./dnsApiToken.age;
  };
  age.secrets.netdata_nixos_claim = {
    file = ./netdata_nixos_claim.age;
  };

  age.secrets.resticb2env = {
    # contents:
    # RCLONE_REMOTE=<rclone path>
    # HC_UUID=<uuid for healthchecks>
    file = ./restic/b2.env.age;
  };

  age.secrets.rcloneConf = {
    # contents: rclone.conf file contents with NAS and B2 access info
    file = ./rclone.conf.age;
    owner = "restic";
  };

  age.secrets.restic-localstorage-env = {
    # contents:
    # HC_UUID=<uuid for healthchecks>
    file = ./restic/localstorage.env.age;
  };

  age.secrets.restic-localstorage-pass = {
    # contents: password for restic repo
    file = ./restic/localstorage.pass.age;
    owner = "restic";
  };

  # contents: HC_UUID=<uuid>
  age.secrets.resticLanEnv.file = ./restic/nas.env.age;

  # contents: repo password
  # age.secrets.resticpass = {
  #   file = ./restic/nas.pass.age;
  #   owner = "restic";
  # };

  # contents: password for rsyncd
  age.secrets.rsyncd-secrets = {
    file = ./rsyncd-secrets.age;
  };
}