# treefmt.nix
_: {
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;
}
