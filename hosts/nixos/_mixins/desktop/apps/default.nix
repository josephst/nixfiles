{inputs, pkgs, ...}: {
  imports = [
    ./steam.nix
  ];

  environment.systemPackages = [
    inputs.ghostty.packages.${pkgs.system}.default # ghostty terminal
  ];
}
