{
  description = "Flake for building Dashy";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          dashy = nixpkgs.legacyPackages.${system}.callPackage ./default.nix {};
          default = dashy;
        };
        overlays.default = import ./overlay.nix;
      }
      );
}
