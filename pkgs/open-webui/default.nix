{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  version = "v0.1.122"; # version tag
  pname = "open-webui";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = lib.fakeHash;
  };

  backend = pkgs.callPackage ./backend.nix { inherit src; };
  frontend = pkgs.callPackage ./frontend.nix { inherit src; };
in
{}
