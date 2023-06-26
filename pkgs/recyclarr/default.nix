{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  icu,
  zlib,
  xmlstarlet,
}:
buildDotnetModule rec {
  pname = "recyclarr";
  version = "4.4.1";
  src = fetchFromGitHub {
    owner = "recyclarr";
    repo = pname;
    rev = "b3cf0cd";
    sha256 = "sha256-xpuVjkWrKUvE6OP/3b1ZA8+mHDcXrrp6+kiULkpCPuU=";
  };

  nativeBuildInputs = [xmlstarlet];

  preConfigure = ''
    xmlstarlet ed --inplace --delete "configuration/packageSourceMapping" src/nuget.config
    xmlstarlet ed --inplace --subnode "Project/PropertyGroup[GitVersionBaseDirectory]" -t elem -n DisableGitVersionTask -v true src/Directory.Build.props
    substituteInPlace src/Recyclarr.Cli/Program.cs --replace "GitVersionInformation.InformationalVersion" "\"v${version}-nix\""
  '';

  projectFile = "src/Recyclarr.Cli/Recyclarr.Cli.csproj";

  # File generated with `nix build .#recyclarr.fetch-deps` from project root directory
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_7_0;
  dotnet-runtime = dotnetCorePackages.runtime_7_0;

  executables = ["recyclarr"]; # This wraps "$out/lib/$pname/foo" to `$out/bin/foo`.

  runtimeDeps = [icu zlib stdenv.cc.cc.lib]; # This will wrap each library path into `LD_LIBRARY_PATH`.

  meta = with lib; {
    description = "Automatically sync TRaSH guides to your Sonarr and Radarr instances";
    homepage = "https://recyclarr.dev";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
