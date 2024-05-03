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

  npmDepsHash = "sha256-JlrUHOWqGOHhWQH193yCUZbT+SyDCjYPANjsLkmCT1o=";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv ./build $out/lib

    runHook postInstall
  '';
}