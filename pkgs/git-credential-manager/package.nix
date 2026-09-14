{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  libsecret,
  git,
  git-credential-manager,
  gnupg,
  pass,
  stdenv,
  testers,
  withLibsecretSupport ? true,
  withGpgSupport ? true,
}:

buildDotnetModule rec {
  pname = "git-credential-manager";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "git-ecosystem";
    repo = "git-credential-manager";
    rev = "v${version}";
    hash = "sha256-4URkx5Z2sfNFsh1do6ludR86UghyukfeiN/UZ9yOvlU=";
  };

  projectFile = "src/shared/Git-Credential-Manager/Git-Credential-Manager.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk =
    if stdenv.hostPlatform.isDarwin then
      dotnetCorePackages.sdk_10_0-bin
    else
      dotnetCorePackages.sdk_10_0;
  dotnet-runtime =
    if stdenv.hostPlatform.isDarwin then
      dotnetCorePackages.runtime_10_0-bin
    else
      dotnetCorePackages.runtime_10_0;
  dotnetInstallFlags = [
    "--framework"
    "net10.0"
  ];
  executables = [ "git-credential-manager" ];

  runtimeDeps = lib.optional withLibsecretSupport libsecret;
  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath (
        [ git ]
        ++ lib.optionals withGpgSupport [
          gnupg
          pass
        ]
      )
    }"
    "--inherit-argv0"
  ];

  passthru.tests.version = testers.testVersion {
    package = git-credential-manager;
  };

  meta = {
    description = "Secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services";
    homepage = "https://github.com/git-ecosystem/git-credential-manager";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ _999eagle ];
    longDescription = ''
      git-credential-manager is a secure, cross-platform Git credential storage with authentication to GitHub, Azure Repos, and other popular Git hosting services.

      > requires sandbox to be disabled on MacOS, so that
      .NET can find `/usr/bin/codesign` to sign the compiled binary.
      This problem is common to all .NET packages on MacOS with Nix.
    '';
    mainProgram = "git-credential-manager";
  };
}
