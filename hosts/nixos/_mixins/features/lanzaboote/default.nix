{ lib
, pkgs
, inputs
, hostname
, ...
}:
let
  installOn = [
    "terminus"
  ];
in lib.mkIf (builtins.elem hostname installOn) {
  boot = {
    loader = {
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = lib.mkForce false;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
  environment.systemPackages = [ pkgs.sbctl ];
}
