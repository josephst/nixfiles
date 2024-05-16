{
  lib,
  mkYarnPackage,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nodejs,
  writeText,
}:
let
  defaultConfig = builtins.readFile ./conf.yml.default;
in
mkYarnPackage rec {
  name = "dashy";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "Lissy93";
    repo = name;
    rev = "2ec404121a3b14fe4497996c8786fb5d4eda14e5";
    fetchSubmodules = false;
    sha256 = "sha256-kW/4eAswWboLSwmHpkPOUoOFWxOyxkqb7QBKM/ZTJKw=";
  };

  NODE_OPTIONS = "--openssl-legacy-provider";

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = "sha256-fyHgMLAZBL0hifUguWe465X6qSX5pOwoX2dQPHEF6hU";
  };

  nativeBuildInputs = [ makeWrapper ];

  configFile = writeText "conf.yml" defaultConfig;

  preConfigure = ''
    rm public/conf.yml
    ln -s $configFile public/conf.yml
  '';

  buildPhase = ''
    runHook preBuild

    # Yarn writes cache directories etc to $HOME.
    export HOME=$(mktemp -d)

    ln -s $src/package.json package.json
    yarn build --offline --non-interactive --mode production

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv deps/Dashy/dist/* $out

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/dashy" --add-flags "$out/libexec/Dashy/deps/Dashy/server.js"
  '';

  dontFixup = true;
  distPhase = "true";

  meta = {
    description = "A self-hostable personal dashboard built for you. Includes status-checking, widgets, themes, icon packs, a UI editor and tons more!";
    homepage = "https://dashy.to/";
    license = lib.licenses.mit;
  };
}
