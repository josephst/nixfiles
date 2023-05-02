# Recyclarr

## Updating
Run `nix hash to-sri --type sha256 $(nix-prefetch-url --type sha256 https://github.com/recyclarr/recyclarr/releases/download/v4.4.1/recyclarr-linux-x64.tar.xz)` to get new hashes for package versions. 
Replace `linux` and `x64` with desired platform, and update `v4.4.1` to the desired version. 

Then, update the hashes in `default.nix` with the new hashes and update the `version` string. 
