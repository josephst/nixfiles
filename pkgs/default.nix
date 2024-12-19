# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix) { }
,
}:
rec {
  # recyclarr = pkgs.callPackage ./recyclarr { };
  healthchecks-ping = pkgs.callPackage ./healthchecks-ping.nix { };

  smartrent-py = pkgs.python3.pkgs.callPackage ./smartrent-py.nix { };
  homeassistant-smartrent = pkgs.callPackage ./homeassistant-smartrent.nix { inherit smartrent-py; };
}
