{ config
, lib
, ...
}:
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
      autoUpdate = true;
      upgrade = true;

      # Declarative package management by removing all homebrew packages,
      # not declared in darwin-nix configuration
      cleanup = lib.mkDefault "uninstall";
    };
  };
}
