{ ... }:
{
  imports = [
    # global config
    ../common
    ../../common

    # machine-specific config
    ./brew.nix
    ./orbstack.nix
  ];

  # TODO: lower hostSpec into this file
}
