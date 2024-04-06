{ config, pkgs, ... }:
let
  checkOpts = [
    "--read-data-subset 500M"
    "--with-cache"
  ];
  localPath = "/storage/restic";
in
{
  # checks the repo on B2 - pruning not necessary since deletes locally will be sync'd to B2
  services.restic.backups.b2-check = {
    initialize = false;
    user = "restic";
    # ...
  };
}
