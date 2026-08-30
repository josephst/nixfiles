{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bash,
  coreutils,
  curl,
  gnugrep,
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
    mkdir -p "$SCAN_DIR"' \
          --replace-fail 'OUTPUT=~/brscan/brscan_"$(date +%Y-%m-%d-%H-%M-%S)".tif' \
            'OUTPUT="$SCAN_DIR/brscan_$(date +%Y-%m-%d-%H-%M-%S).tif"'

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
