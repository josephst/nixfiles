{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bash,
  coreutils,
  curl,
  gnugrep,
  libtiff,
  libredirect,
  makeWrapper,
  nix-update-script,
  rpmextract,
  sane-backends,
}:

stdenv.mkDerivation rec {
  pname = "brscan-skey";
  version = "0.3.5";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf006650/${pname}-${version}-0.x86_64.rpm";
    hash = "sha256-AdyFnxl45kUUfO1exLVEjMPiaxxtLxEEg09YkcDhdGk=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    rpmextract
  ];

  buildInputs = [ sane-backends ];

  unpackPhase = ''
    rpmextract $src
  '';

  postPatch = ''
            # The vendor's file action defaults to ~/brscan. Keep the standalone
            # command compatible while allowing the system service to select a
            # dedicated, shared directory through BRSCAN_SKEY_SCAN_DIR.
            substituteInPlace opt/brother/scanner/brscan-skey/script/scantofile.sh \
              --replace-fail 'mkdir -p ~/brscan' \
            'SCAN_DIR="''${BRSCAN_SKEY_SCAN_DIR:-$HOME/brscan}"
        STAGING_DIR="''${BRSCAN_SKEY_STAGING_DIR:-$HOME/.brscan-skey-staging}"
        mkdir -p "$SCAN_DIR" "$STAGING_DIR"
        TIFFCP="${libtiff}/bin/tiffcp"
        TIFF2PDF="${libtiff}/bin/tiff2pdf"' \
              --replace-fail 'OUTPUT=~/brscan/brscan_"$(date +%Y-%m-%d-%H-%M-%S)".tif' \
                'OUTPUT="$SCAN_DIR/brscan_$(date +%Y-%m-%d-%H-%M-%S).pdf"
        STAGING_BASENAME="$(basename "$OUTPUT" .pdf)"
        STAGING_OUTPUT="$STAGING_DIR/$STAGING_BASENAME.tif"
        COMPRESSED_OUTPUT="$STAGING_DIR/$STAGING_BASENAME.lzw.tif"
        STAGING_PDF="$STAGING_DIR/$STAGING_BASENAME.pdf"' \
              --replace-fail 'OPT_FILE="--outputfile  $OUTPUT"' \
                'OPT_FILE="--outputfile  $STAGING_OUTPUT"' \
              --replace-fail \
                '$SCANIMAGE $OPT

    if [ ! -e "$OUTPUT" ];then
       sleep 1
       $SCANIMAGE $OPT
    fi

    echo "$OUTPUT" is created.' \
                'run_scan() {
      rm -f -- "$STAGING_OUTPUT"
      $SCANIMAGE $OPT
    }

    run_scan

    if [ ! -s "$STAGING_OUTPUT" ];then
       sleep 1
       run_scan
    fi

    if [ ! -s "$STAGING_OUTPUT" ];then
       echo "Scan failed: $STAGING_OUTPUT is empty" >&2
       rm -f -- "$STAGING_OUTPUT"
       exit 1
    fi

    rm -f -- "$COMPRESSED_OUTPUT" "$STAGING_PDF"
    if ! "$TIFFCP" -c lzw "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT";then
       echo "Scan failed: could not compress $STAGING_OUTPUT" >&2
       rm -f -- "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT"
       exit 1
    fi

    if ! "$TIFF2PDF" "$COMPRESSED_OUTPUT" > "$STAGING_PDF" || [ ! -s "$STAGING_PDF" ];then
       echo "Scan failed: could not convert $STAGING_OUTPUT to PDF" >&2
       rm -f -- "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT" "$STAGING_PDF"
       exit 1
    fi

    PUBLISH_OUTPUT="$SCAN_DIR/.$(basename "$OUTPUT").part"
    rm -f -- "$PUBLISH_OUTPUT"
    if ! cp -- "$STAGING_PDF" "$PUBLISH_OUTPUT" || [ ! -s "$PUBLISH_OUTPUT" ];then
       echo "Scan failed: could not publish $OUTPUT" >&2
       rm -f -- "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT" "$STAGING_PDF" "$PUBLISH_OUTPUT"
       exit 1
    fi

    mv -- "$PUBLISH_OUTPUT" "$OUTPUT"
    rm -f -- "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT" "$STAGING_PDF"

    echo "$OUTPUT" is created.'

            patchShebangs opt/brother/scanner/brscan-skey
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a opt "$out/"

    # The vendor shell launcher invokes its helper with an absolute path.
    # Point that one launcher edge at the immutable Nix store copy; the
    # helper's own /opt lookups are handled by the wrapper below or the
    # service's mount namespace.
    substituteInPlace "$out/opt/brother/scanner/brscan-skey/brscan-skey" \
      --replace-fail \
        '/opt/brother/scanner/brscan-skey/brscan-skey-exe' \
        "$out/opt/brother/scanner/brscan-skey/brscan-skey-exe"

    # The binaries and vendor scripts use Brother's traditional absolute
    # /opt and /etc/opt paths. Redirect those paths for direct invocations;
    # the NixOS service uses an equivalent read-only mount namespace.
    makeWrapper \
      "$out/opt/brother/scanner/brscan-skey/brscan-skey" \
      "$out/bin/brscan-skey" \
      --prefix PATH : "${
        lib.makeBinPath [
          bash
          coreutils
          curl
          gnugrep
        ]
      }" \
      --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS \
        "/opt/brother/scanner/brscan-skey=$out/opt/brother/scanner/brscan-skey:/etc/opt/brother/scanner/brscan-skey=$out/opt/brother/scanner/brscan-skey"

    mkdir -p "$out/share/licenses/$pname"
    cp -p "$out/opt/brother/scanner/brscan-skey/LICENSE_ENG.txt" \
      "$out/share/licenses/$pname/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Brother scan-key tool for starting scans from a device button";
    homepage = "https://support.brother.com/";
    license = lib.licenses.unfree;
    mainProgram = "brscan-skey";
    maintainers = with lib.maintainers; [ josephst ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
