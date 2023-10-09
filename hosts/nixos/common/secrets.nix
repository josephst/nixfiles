{ config, pkgs, agenix, secrets, ... }:

let user = "joseph"; in
{

  age.identityPaths = [
    "/home/${user}/.ssh/id_ed25519"
  ];

  age.secrets.smb = {
    file = "${secrets}/smb.age";
    owner = "root";
    group = "root";
  };
  age.secrets.dnsApiToken = {
    file = "${secrets}/dnsApiToken.age";
  };
  age.secrets.netdata_nixos_claim = {
    file = "${secrets}/netdata_nixos_claim.age";
  };

  age.secrets.resticb2env = {
    # contents:
    # RCLONE_LOCAL=<rclone path>
    # RCLONE_REMOTE=<rclone path>
    # RESTIC_REPOSITORY=<restic path to b2 repository (ie rclone:b2:...)
    # HC_UUID=<uuid for healthchecks>
    file = "${secrets}/restic/b2.env.age";
  };

  age.secrets.rcloneConf = {
    # contents: rclone.conf file contents with NAS and B2 access info
    file = "${secrets}/rclone/rclone.conf.age";
    owner = "restic";
  };

  age.secrets.restic-exthdd-env = {
    # contents:
    # HC_UUID=<uuid for healthchecks>
    file = "${secrets}/restic/exthdd.env.age";
  };

  age.secrets.restic-exthdd-pass = {
    # contents: password for restic repo
    file = "${secrets}/restic/exthdd.pass.age";
    owner = "restic";
  };

  age.secrets.resticLanEnv.file = "${secrets}/restic/nas.env.age";
  # contents: HC_UUID=<uuid>

  age.secrets.resticpass = {
    file = "${secrets}/restic/nas.pass.age";
    owner = "restic";
  };
  # contents: repo password

  age.secrets.joseph.file = "${secrets}/users/joseph.age";

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
