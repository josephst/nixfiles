{
  src,
  version,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "open-webui-backend";
  inherit src version;

  dontBuild = true; # just need to copy python files

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -R ./backend $out/lib

    runHook postInstall
  '';

  # tries to copy favicon file, but Nix store is read-only so skip this step
  postInstall = ''
    substituteInPlace $out/lib/backend/config.py \
      --replace-warn "shutil.copyfile(frontend_favicon, f\"{STATIC_DIR}/favicon.png\")" \
        "pass"
  '';
}
