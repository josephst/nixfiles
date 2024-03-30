{ pkgs, ... }:
let
  replacements = [
    # {
    #   #https://discourse.nixos.org/t/cve-2024-3094-malicious-code-in-xz-5-6-0-and-5-6-1-tarballs
    #   original = pkgs.xz;
    #   replacement = pkgs.xz.overrideAttrs (old: rec {
    #     version = "5.4.6";
    #     src = pkgs.fetchurl {
    #       url = "mirror://sourceforge/lzmautils/xz-${version}.tar.bz2";
    #       sha256 = "sha256-kThRsnTo4dMXgeyUnxwj6NvPDs9uc6JDbcIXad0+b0k=";
    #     };
    #   });
    # }
  ];
in
{
  system.replaceRuntimeDependencies = replacements;
  # grafting is impure :(
  system.autoUpgrade.flags = if replacements == [ ] then [ ] else [ "--impure" ];
}
