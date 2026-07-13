# A nixpkgs instance that is grabbed from the pinned nixpkgs commit in the lock file
# This is useful to avoid using channels when using legacy nix commands
let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsNode = flakeLock.nodes.${flakeLock.nodes.root.inputs.nixpkgs};
  lock = nixpkgsNode.locked;
in
import (
  fetchTarball {
    url = "https://github.com/${lock.owner}/${lock.repo}/archive/${lock.rev}.tar.gz";
    sha256 = lock.narHash;
  }
)
