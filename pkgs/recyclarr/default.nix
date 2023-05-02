{
  lib,
  stdenv,
  fetchurl,
  pkgs,
}: let
  # TODO: run on windows too?
  os =
    if stdenv.isDarwin
    then "osx"
    else "linux";
  arch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      aarch64-darwin = "arm64";
    }
    ."${stdenv.hostPlatform.system}"
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  hash =
    {
      x64-linux_hash = "sha256-EOTxLQrYumnb7khhC2H7Desw9YjpziWOkyBaToE06uw=";
      arm64-linux_hash = "sha256-gcL8WrHkmpqyodluLFplRu7prSk81h+oas50cKOqCOI=";
      x64-osx_hash = "sha256-tQKUsbaVKhP4hMK/byoJt0R7vrXq6fE9bPvZUyWfVVw=";
      arm64-osx_hash = "sha256-bdpXdLAdHufJzWuv/c+pGNC3HsiXWOA1WIZam25UuQY=";
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "recyclarr";
    version = "v4.4.1";

    src = fetchurl {
      url = "https://github.com/recyclarr/recyclarr/releases/download/${version}/recyclarr-${os}-${arch}.tar.xz";
      hash = hash;
    };

    # Work around the "unpacker appears to have produced no directories"
    # case that happens when the archive doesn't have a subdirectory.
    # setSourceRoot = "sourceRoot=`pwd`";
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -r * $out/bin

      runHook postInstall
    '';

    dontFixup = true; # breaks self-contained .net apps

    meta = with lib; {
      description = "A command-line application that will automatically synchronize recommended settings from the TRaSH guides to your Sonarr/Radarr instances.";
      homepage = "https://github.com/recyclarr/recyclarr";
      license = licenses.mit;
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    };
  }
