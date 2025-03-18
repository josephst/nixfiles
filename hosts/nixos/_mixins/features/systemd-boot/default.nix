# Add this mixin to machines that boot with EFI
{ lib
, hostname
, ...
}:
let
  installOn = [
    "terminus"
    "vmware"
  ];
in
lib.mkIf (builtins.elem hostname installOn) {
  # Only enable during install
  #boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd-boot to boot EFI machines
  boot.loader.systemd-boot.configurationLimit = lib.mkOverride 1337 10;
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.timeout = 3;
}
