{
  writeShellApplication,
  deadnix,
  nixfmt-rfc-style,
  statix,
}:

# based on nixfmt-plus by jnsgruk (https://github.com/jnsgruk/nixos-config/blob/main/pkgs/nixfmt-plus.nix)
# Licensed under Apache-2.0
writeShellApplication {
  name = "nixfmt-plus";
  runtimeInputs = [
    deadnix
    nixfmt-rfc-style
    statix
  ];
  text = ''
    set -x
    deadnix --edit
    statix fix
    nixfmt .
  '';
}
