{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "ZacheryThomas";
  domain = "smartrent";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "ZacheryThomas";
    repo = "homeassistant-smartrent";
    rev = "v${version}";
    hash = "sha256-h2oC3Aak6+tO+YCD0UrEROuJtJWg7Zq6iniNg4Lxug8=";
  };

  dependencies = [
    # python requirements, as specified in manifest.json
    (home-assistant.python3Packages.callPackage ../../../pkgs/smartrent-py/package.nix { })
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--system"
      "x86_64-linux"
      "--override-filename"
      "pkgsLinux/homeassistant-customcomponents/smartrent/package.nix"
    ];
  };

  meta = with lib; {
    # changelog, description, homepage, license, maintainers
    description = "Home Assistant Custom Component for SmartRent Locks, Thermostats, Sensors, and Switches";
    homepage = "https://github.com/ZacheryThomas/homeassistant-smartrent/";
    license = licenses.mit;
    maintainers = with maintainers; [ josephst ];
    changelog = "https://github.com/ZacheryThomas/homeassistant-smartrent/releases";
  };
}
