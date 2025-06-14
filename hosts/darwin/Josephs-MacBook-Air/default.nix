{ ... }:
{
  imports = [
    # global config
    ../common # nix-darwin
    ../../common # nix-darwin AND NixOS

    # machine-specific config
    ./brew.nix
    ./orbstack.nix
  ];
}
