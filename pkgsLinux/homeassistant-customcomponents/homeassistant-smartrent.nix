{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, home-assistant
, nix-update-script
}:

buildHomeAssistantComponent rec {
  owner = "ZacharyThomas";
  domain = "smartrent";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "ZacheryThomas";
    repo = "homeassistant-smartrent";
    rev = "v${version}";
    hash = "sha256-FIfTrbIGP7FztvifI9wVLtepQZKwd70xImncmoYGu6k=";
  };

  dependencies = [
    # python requirements, as specified in manifest.json
    (home-assistant.python.pkgs.callPackage ../../pkgs/smartrent-py.nix { })
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    # changelog, description, homepage, license, maintainers
    description = "Home Assistant Custom Component for SmartRent Locks, Thermostats, Sensors, and Switches";
    homepage = "https://github.com/ZacheryThomas/homeassistant-smartrent/";
    license = licenses.mit;
    maintainers = with maintainers; [ josephst ];
    changelog = "https://github.com/ZacheryThomas/homeassistant-smartrent/releases";
  };
}
