{ ... }:

let user = "joseph"; in
{
  # secrets specific to this device
  age.secrets.smb = {
    file = "../../../smb.age";
    owner = "root";
    group = "root";
  };
  age.secrets.dnsApiToken = {
    file = "../../../dnsApiToken.age";
  };
  age.secrets.netdata_nixos_claim = {
    file = "../../../netdata_nixos_claim.age";
  };

  age.secrets.resticb2env = {
    # contents:
    # RCLONE_LOCAL=<rclone path>
    # RCLONE_REMOTE=<rclone path>
    # RESTIC_REPOSITORY=<restic path to b2 repository (ie rclone:b2:...)
    # HC_UUID=<uuid for healthchecks>
    file = "../../../restic/b2.env.age";
  };

  age.secrets.rcloneConf = {
    # contents: rclone.conf file contents with NAS and B2 access info
    file = "../../../rclone/rclone.conf.age";
    owner = "restic";
  };

  age.secrets.restic-exthdd-env = {
    # contents:
    # HC_UUID=<uuid for healthchecks>
    file = "../../../restic/exthdd.env.age";
  };

  age.secrets.restic-exthdd-pass = {
    # contents: password for restic repo
    file = "../../../restic/exthdd.pass.age";
    owner = "restic";
  };

  # contents: HC_UUID=<uuid>
  age.secrets.resticLanEnv.file = "../../../restic/nas.env.age";

  # contents: repo password
  age.secrets.resticpass = {
    file = "../../../restic/nas.pass.age";
    owner = "restic";
  };

  # contents: password for rsyncd
  age.secrets.rsyncd-secrets = {
    file = "../../../rsyncd-secrets.age";
  };

  ###########################

  # age.secrets."github-ssh-key" = {
  #   symlink = false;
  #   path = "/home/${user}/.ssh/id_github";
  #   file =  "${secrets}/github-ssh-key.age";
  #   mode = "600";
  #   owner = "${user}";
  #   group = "wheel";
  # };

  # age.secrets."github-signing-key" = {
  #   symlink = false;
  #   path = "/home/${user}/.ssh/pgp_github.key";
  #   file =  "${secrets}/github-signing-key.age";
  #   mode = "600";
  #   owner = "${user}";
  #   group = "wheel";
  # };

}
