# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? (import ../nixpkgs.nix) {},
  inputs,
}: {
  # dashy = pkgs.callPackage ./dashy {};
  # git-credential-manager = pkgs.callPackage ./git-credential-manager {};
  llama-cpp = inputs.llama-cpp.packages."${pkgs.system}".default;
  # recyclarr = pkgs.callPackage ./recyclarr {}; # merged into nixpkgs upstream
}
