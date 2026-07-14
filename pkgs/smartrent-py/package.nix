{
  lib,
  buildPythonPackage,
  fetchPypi,
  # runtime
  websockets,
  aiohttp,
  # build
  setuptools,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "smartrent-py";
  version = "0.5.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PRHRLAv6/7zwyq3HKJkgWofpVl1vdwrcBqqdp7PNEoc=";
  };

  dependencies = [
    websockets
    aiohttp
  ];

  pythonRelaxDeps = [
    # Upstream's Poetry ^15 constraint excludes nixpkgs' websockets 16 even
    # though the imported client API remains compatible.
    "websockets"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
    --replace poetry.masonry.api poetry.core.masonry.api \
    --replace "poetry>=" "poetry-core>="
  '';

  build-system = [
    poetry-core
    setuptools
  ];

  # The PyPI source archive contains no test suite; retain an import check so
  # dependency/API breakage still fails the build at package time.
  doCheck = false;
  pythonImportsCheck = [ "smartrent" ];

  meta = with lib; {
    description = "Api for SmartRent locks, thermostats, moisture sensors, and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent-py";
    license = licenses.mit;
    maintainers = with maintainers; [ josephst ];
  };
}
