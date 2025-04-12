# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{ pkgs ? (import ../nixpkgs.nix { })
,
}:
{
  hass-smartrent =
    pkgs.home-assistant.python.pkgs.callPackage ./homeassistant-customcomponents/smartrent/package.nix { };
}
