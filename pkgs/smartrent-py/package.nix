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
  version = "0.5.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QnRkn7sq/ILNVAdb58OosbVQp0oviSGVkB/sPHATkhk=";
  };

  dependencies = [
    websockets
    aiohttp
  ];

  pythonRelaxDeps = [
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

  doCheck = true;

  pythonImportsCheck = [ "smartrent" ];

  meta = with lib; {
    description = "Api for SmartRent locks, thermostats, moisture sensors, and switches";
    homepage = "https://github.com/ZacheryThomas/smartrent-py";
    license = licenses.mit;
    maintainers = with maintainers; [ josephst ];
  };
}
