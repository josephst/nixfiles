# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { overlays = [
  (import ../overlays/modifications.nix)
  (import ../overlays/additions.nix)
  ];}
,
}:
{
  # recyclarr = pkgs.callPackage ./recyclarr { };
  smartrent-py = pkgs.python3.pkgs.callPackage ./smartrent-py.nix { };

  # able to use overlays here
  # zwave-js-server = pkgs.zwave-js-server;
}
