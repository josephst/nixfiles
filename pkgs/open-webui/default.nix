{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  version = "v0.1.124"; # version tag
  pname = "open-webui";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = "sha256-r3oZiN2UIhPAG+ZcsZrXD1OemJrWXXlZdKVhK3+VhhU=";
  };

  # backend acts as reverse proxy, sending requests to ollama
  backend = pkgs.callPackage ./backend.nix { inherit src version; };

  # frontend is the static files
  frontend = pkgs.callPackage ./frontend.nix { inherit src version; };
in
stdenv.mkDerivation {
  inherit pname src version;

  # dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin

    ln -s ${backend}/lib/* $out/lib
    ln -s ${backend}/bin/open-webui $out/bin/

    ln -s ${frontend}/lib/* $out/lib

    runHook postInstall
  '';

  meta = with lib; {
    description = "User-friendly WebUI for LLMs (Formerly Ollama WebUI)";
    homepage = "https://github.com/open-webui/open-webui";
    license = licenses.mit;
    mainProgram = pname;
    maintainers = with maintainers; [ josephst ];
    platforms = platforms.all;
  };
}
