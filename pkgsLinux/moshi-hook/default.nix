{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  curl,
  git,
  gnused,
  nix,
  writeShellApplication,
}:

let
  version = "0.3.20";
  x86_64Hash = "sha256-v7npl4Nj+ksZabIZuJmHn5V2u/oTCW/UbcGRB90zCWc=";
  aarch64Hash = "sha256-D35dUHcJIn7aEWRVcSwa/PKxRZhCxjFe/6zKR4JhTXA=";

  platform =
    {
      x86_64-linux = {
        assetArch = "x86_64";
        hash = x86_64Hash;
      };
      aarch64-linux = {
        assetArch = "arm64";
        hash = aarch64Hash;
      };
    }
    .${stdenv.hostPlatform.system};

  updateScript = writeShellApplication {
    name = "update-moshi-hook";
    runtimeInputs = [
      coreutils
      curl
      git
      gnused
      nix
    ];
    text = builtins.readFile ./update.sh;
  };
in
stdenv.mkDerivation {
  pname = "moshi-hook";
  inherit version;

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${version}/moshi-hook_Linux_${platform.assetArch}.tar.gz";
    inherit (platform) hash;
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 moshi-hook "$out/bin/moshi-hook"
    ln -s moshi-hook "$out/bin/moshi"
    mkdir -p "$out/share/doc/moshi-hook"
    cp -r README.md docs "$out/share/doc/moshi-hook"

    runHook postInstall
  '';

  passthru.updateScript = [
    (lib.getExe updateScript)
    "pkgsLinux/moshi-hook/default.nix"
  ];

  meta = {
    description = "Daemon and CLI bridging coding agents to the Moshi app";
    homepage = "https://getmoshi.app";
    license = lib.licenses.unfree;
    mainProgram = "moshi-hook";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
