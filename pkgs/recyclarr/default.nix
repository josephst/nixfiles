{
  lib,
  nixosTests,
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
      x64-linux_hash = "sha256-96j29Su983CaCVOBHoGduY/0BCWY6cONwub7yCFFIgM=";
      arm64-linux_hash = "sha256-/Xqa2IbTafbYytKG/8jLvNjKAnNcgValDa15nvbzSR8=";
      x64-osx_hash = "sha256-FbDeQd7z5KCIPRBbB/mnnATnSYMaoehBlUljSw87L7M=";
      arm64-osx_hash = "sha256-KTYYEbq2MZaHzxQHO01qeH6PQ7zHy/gW5HaTIDiO0Z8=";
    }
    ."${arch}-${os}_hash";
in
  stdenv.mkDerivation rec {
    pname = "recyclarr";
    version = "v4.3.0";

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
