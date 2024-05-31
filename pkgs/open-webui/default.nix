{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script
}:
let
  version = "0.1.125";
  pname = "open-webui";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-t7bzsrphUKeg7AcM8KK4usecwGNnYCjtBI2Ad+bsrZI=";
  };

  # backend acts as reverse proxy, sending requests to ollama
  backend = pkgs.callPackage ./backend.nix { inherit src version; };

  # frontend is the static files
  frontend = buildNpmPackage {
    pname = "open-webui-frontend";
    inherit src version;

    npmDepsHash = "sha256-s4u7ySIiobZJOy/oKhJKoHSaC9Eu6Doao9p2iWgbC88=";

    env = {
      CYPRESS_INSTALL_BINARY = 0;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      mv ./build $out/lib

      runHook postInstall
    '';
  };
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

  passthru = {
    inherit (frontend) npmDeps; # make npmDeps visible to nix-update-script
    updateScript = nix-update-script {};
  };

  meta = with lib; {
    description = "User-friendly WebUI for LLMs (Formerly Ollama WebUI)";
    homepage = "https://github.com/open-webui/open-webui";
    license = licenses.mit;
    mainProgram = pname;
    maintainers = with maintainers; [ josephst ];
    platforms = platforms.all;
  };
}
