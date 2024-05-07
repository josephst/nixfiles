{ config, lib, ... }:
let
  user = "joseph";
in
{
  age.identityPaths =
    [
      # make sure this key is copied from 1password prior to running agenix
      "/home/${user}/.ssh/id_ed25519"
      # key to use for new installs, prior to generation of hostKeys
      "/etc/agenixKey"
    ]
    ++ map (e: e.path) (
      lib.filter (e: e.type == "rsa" || e.type == "ed25519") config.services.openssh.hostKeys
    );

  age.secrets.joseph.file = ../../../secrets/users/joseph.age;

  age.secrets = {
    "gh/hosts.yml" = {
      file = "../../secrets/gh_hosts.yml.age";
      path = "/home/${user}/.config/gh/hosts.yml";
      owner = user;
    };
  }

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
