{
  lib,
  mkYarnPackage,
  fetchFromGitHub,
  fetchYarnDeps,
}:
mkYarnPackage rec {
  name = "dashy";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "Lissy93";
    repo = name;
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-8+J0maC8M2m+raiIlAl0Bo4HOvuuapiBhoSb0fM8f9M=";
  };

  NODE_OPTIONS = "--openssl-legacy-provider";

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    sha256 = "sha256-RxreSjhbWovPbqjK6L9GdIEhH4uVY+RvWyJYwIytn4g=";
  };

  buildPhase = ''
    # Yarn writes cache directories etc to $HOME.
    export HOME=$(mktemp -d)
    ln -s $src/package.json package.json

    yarn --offline build
    ls -la deps/Dashy
    mkdir -v $out
    mv deps/Dashy/dist $out
  '';

  dontInstall = true;
  distPhase = "true";
  dontFixup = true;

  meta = with lib; {
    description = "A self-hostable personal dashboard built for you. Includes status-checking, widgets, themes, icon packs, a UI editor and tons more!";
    homepage = "https://dashy.to/";
    license = licenses.mit;
  };
}
