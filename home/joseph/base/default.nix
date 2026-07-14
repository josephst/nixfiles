{ lib, osConfig, ... }:
let
  isMinimal = osConfig.hostSpec.cliProfile == "minimal";
in
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./bottom.nix # system viewer
    ./bun.nix
    ./direnv.nix
    ./eza.nix # better ls
    ./fd.nix # better find
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./helix.nix
    ./packages.nix
    ./programs.nix
    ./service-credentials.nix
    ./ssh.nix
    ./starship.nix
  ]
  ++ lib.optionals (!isMinimal) [
    ./nushell
    ./zellij
  ];
}
