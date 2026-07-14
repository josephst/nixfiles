# treefmt.nix
_: {
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs = {
    actionlint.enable = true;
    deadnix.enable = true;
    just.enable = true;
    nixfmt.enable = true;
    shellcheck.enable = true;
    statix.enable = true;
  };
}
