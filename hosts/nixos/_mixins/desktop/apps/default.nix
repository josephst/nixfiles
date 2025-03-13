{inputs, pkgs, ...}: {
  environment.systemPackages = [
    inputs.ghostty.packages.${pkgs.system}.default # ghostty terminal
  ];
}
