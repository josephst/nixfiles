{
  src,
  version,
  lib,
  buildNpmPackage,
  ...
}:
buildNpmPackage {
  inherit src version;
  pname = "open-webui-frontend";

  env = {
    CYPRESS_INSTALL_BINARY = 0;
  };

  npmDepsHash = "sha256-uLp8QlPUR1dfchwu0IhJ8FFMMkm3V+FK2KBc41Un86g=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv ./build $out/lib

    runHook postInstall
  '';
}
