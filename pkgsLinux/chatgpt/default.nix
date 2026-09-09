{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  file,
  makeShellWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  coreutils,
  cups,
  curl,
  dbus,
  expat,
  gdk-pixbuf,
  git,
  glib,
  gnused,
  gtk3,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  nix,
  pango,
  systemd,
  udev,
  writeShellApplication,
  xdg-utils,
}:
let
  updateScript = writeShellApplication {
    name = "update-chatgpt";
    runtimeInputs = [
      coreutils
      curl
      dpkg
      git
      gnused
      nix
    ];
    text = builtins.readFile ./update.sh;
  };
in
stdenv.mkDerivation (_finalAttrs: {
  pname = "chatgpt";
  version = "26.901.41600";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = "sha256-Fc9CKnfo8op1U9MYC4xyeEqZRDihQXhMgtcs3pPvync=";
  };

  nativeBuildInputs = [
    dpkg
    file
    makeShellWrapper
    wrapGAppsHook3
  ];

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase =
    let
      libraryPath = lib.makeLibraryPath [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        gtk3
        libdrm
        libgbm
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        nspr
        nss
        pango
        systemd
      ];
    in
    ''
      runHook preInstall

      mkdir -p $out/bin $out/lib $out/share
      cp -a usr/lib/chatgpt $out/lib/
      cp -a usr/share/applications usr/share/doc usr/share/pixmaps $out/share/

      interpreter="$(cat $NIX_CC/nix-support/dynamic-linker)"
      while IFS= read -r executable; do
        if ${file}/bin/file "$executable" | grep -q 'ELF 64-bit.*x86-64.*dynamically linked'; then
          if patchelf --print-interpreter "$executable" >/dev/null 2>&1; then
            patchelf --set-interpreter "$interpreter" "$executable"
          fi
          patchelf --add-rpath "${libraryPath}:$out/lib/chatgpt" "$executable"
        fi
      done < <(find $out/lib/chatgpt -type f)

      ln -s ../lib/chatgpt/codex-launcher $out/bin/chatgpt

      runHook postInstall
    '';

  preFixup = ''
    makeShellWrapper $out/lib/chatgpt/codex-launcher $out/bin/.chatgpt-wrapped \
      "''${gappsWrapperArgs[@]}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]} \
      --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto}"
    rm $out/bin/chatgpt
    mv $out/bin/.chatgpt-wrapped $out/bin/chatgpt
  '';

  passthru.updateScript = [
    (lib.getExe updateScript)
    "pkgsLinux/chatgpt/default.nix"
  ];

  meta = {
    description = "ChatGPT desktop app with Codex integration";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
