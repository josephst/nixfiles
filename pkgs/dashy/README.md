# Dashy

NOTE: THIS PACKAGE IS NOT IN USE

Need to have the upstream `dashy` package support loading config files from arbitrary locations.
Right now, will only load the (read-only) config file from the nix store.

## Installation
Make sure to have `node2nix2` installed on machine (either in `env.systemPackages` or in `nix develop` shell).
Then, download the `dashy` repo (with `git clone )

`cd` to the repo and run `node2nix --development --nodejs-18 --node-env node-env.nix --output node-deps.nix --composition node-composition.nix`.
Then, copy these files into this directory.
You can now refer to `pkgs.dashy` to install.
