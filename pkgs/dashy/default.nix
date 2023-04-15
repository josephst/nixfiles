{
  lib,
  nixosTests,
  stdenv,
  fetchFromGitHub,
  pkgs,
}: let
  nodejs = pkgs.nodejs-18_x;
in
  stdenv.mkDerivation rec {
    pname = "dashy";
    version = "2.1.1";

    src = fetchFromGitHub {
      owner = "Lissy93";
      repo = "dashy";
      rev = version;
      sha256 = "sha256-8+J0maC8M2m+raiIlAl0Bo4HOvuuapiBhoSb0fM8f9M=";
    };

    nativeBuildInputs = with pkgs; [
      nodejs
      makeWrapper
    ];

    buildPhase = let
      nodeDependencies =
        (import ./node-composition.nix {
          inherit pkgs nodejs;
          inherit (stdenv.hostPlatform) system;
        })
        .nodeDependencies
        .override (old: {
          # access to path '/nix/store/...-source' is forbidden in restricted mode
          src = src;
          dontNpmInstall = true;

          # ERROR: .../.bin/node-gyp-build: /usr/bin/env: bad interpreter: No such file or directory
          # https://github.com/svanderburg/node2nix/issues/275
          preRebuild = ''
            sed -i -e "s|#!/usr/bin/env node|#! ${pkgs.nodejs}/bin/node|" node_modules/node-gyp-build/bin.js
          '';
        });
    in ''
      runHook preBuild

      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export NODE_OPTIONS=--openssl-legacy-provider
      export HOME=$(mktemp -d)
      export PATH="${nodeDependencies}/bin:$PATH"
      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a . $out/share/dashy

      makeWrapper ${nodejs}/bin/node $out/bin/dashy --add-flags $out/share/dashy/server.js

      runHook postInstall
    '';

    passthru = {
      tests = {
        inherit (nixosTests) dashy;
      };
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "Dashy helps you organize your self-hosted services by making them accessible from a single place";
      homepage = "https://github.com/Lissy93/dashy";
      license = licenses.mit;
    };
  }
