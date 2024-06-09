# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) { },
}:
{
  # dashy = pkgs.callPackage ./dashy {};
  # git-credential-manager = pkgs.callPackage ./git-credential-manager {};
  # llama-cpp = inputs.llama-cpp.packages."${pkgs.system}".default;
  # recyclarr = pkgs.callPackage ./recyclarr {}; # merged into nixpkgs upstream
  # open-webui = pkgs.callPackage ./open-webui { };
  nixfmt-plus = pkgs.callPackage ./nixfmt-plus.nix {};
}
