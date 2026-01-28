{ config, lib, ... }:
let
  inherit (config.homebrew) brewPrefix;
in
{
  # Install homebrew if it is not installed
  system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
    lib.mkBefore ''
      if [[ ! -f "${config.homebrew.brewPrefix}/brew" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

  environment.systemPath = lib.mkIf config.homebrew.enable (lib.mkAfter [
    "${brewPrefix}/bin"
    "${brewPrefix}/sbin"
  ]);

  launchd.user.envVariables = lib.mkIf config.homebrew.enable {
    PATH = lib.concatStringsSep ":" config.environment.systemPath;
  };
}
