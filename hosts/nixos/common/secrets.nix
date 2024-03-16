{ ... }:

let user = "joseph"; in
{

  age.identityPaths = [
    # make sure this key is copied from 1password prior to running agenix
    "/home/${user}/.ssh/id_ed25519"
    # also use the built-in key
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets.joseph.file = "../../../users/joseph.age";

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
