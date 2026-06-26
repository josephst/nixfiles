{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Pinned on 2026-06-26 to avoid following Homebrew/install HEAD.
  homebrewInstallScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Homebrew/install/db5debe9b6dac00d87e6a2277a5e2b6c2b0fb773/install.sh";
    hash = "sha256-mSh/GUqLPJ5rAgOhGl+lRRi+VyCTQ+a7lU3sRjV5bZ0=";
  };
in
{
  # Install homebrew if it is not installed
  system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
    lib.mkBefore ''
      if [[ ! -f "${config.homebrew.prefix}/bin/brew" ]]; then
        /bin/bash ${homebrewInstallScript}
      fi
    ''
  );
  homebrew = {
    enable = true;
    global = {
      # only update with `brew update` (or `just update`)
      autoUpdate = false;
    };
    # Don't quarantine apps installed by homebrew with gatekeeper
    caskArgs.no_quarantine = lib.mkDefault true;
    onActivation = {
      autoUpdate = false;
      upgrade = false; # manually update with 'brew update' and 'brew upgrade'

      # Declarative package management by removing all homebrew packages,
      # not declared in darwin-nix configuration
      cleanup = lib.mkDefault "uninstall";
    };

    taps = [ ];

    brews = [
      "mas"
    ];
  };

  environment = lib.mkIf config.homebrew.enable {
    systemPath = lib.mkAfter [
      "${config.homebrew.prefix}/bin"
    ];
    shellInit = ''
      eval $(${config.homebrew.prefix}/bin/brew shellenv)
    '';
  };
}
