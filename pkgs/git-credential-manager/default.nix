{ lib
, stdenv
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, libX11
, libICE
, libSM
, fontconfig
, libsecret
, gnupg
, pass
, withGuiSupport ? true
, withLibsecretSupport ? true
, withGpgSupport ? true
}:

assert withLibsecretSupport -> withGuiSupport;
buildDotnetModule rec {
  pname = "git-credential-manager";
  version = "2.2.2";

  # TODO: get this to run on Mac (currently, code signing of the binary not working,
  # so macOS refuses to run it)

  src = fetchFromGitHub {
    owner = "git-ecosystem";
    repo = "git-credential-manager";
    rev = "v${version}";
    hash = "sha256-XXtir/sSjJ1rpv3UQHM3Kano/fMBch/sm8ZtYwGyFyQ=";
  };

  projectFile = "src/shared/Git-Credential-Manager/Git-Credential-Manager.csproj";
  nugetDeps = ./deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;
  dotnetInstallFlags = [ "--framework" "net7.0" ];
  executables = [ "git-credential-manager" ];

  runtimeDeps = [ fontconfig ]
    ++ lib.optionals withGuiSupport [ libX11 libICE libSM ]
    ++ lib.optional withLibsecretSupport libsecret;
  makeWrapperArgs = lib.optionals withGpgSupport [ "--prefix" "PATH" ":" (lib.makeBinPath [ gnupg pass ]) ];

  # passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services.";
    homepage = "https://github.com/git-ecosystem/git-credential-manager";
    license = with licenses; [ mit ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ _999eagle ];
  };
}
