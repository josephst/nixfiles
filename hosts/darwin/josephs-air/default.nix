{
  inputs,
  pkgs,
  ...
}: let
  hostname = "josephs-air";
in {
  # machine-specific config
  imports = [
    ./brew.nix
    ../shared.nix
  ];

  networking = {
    # need to escape the single quote here
    # https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings
    computerName = "Joseph'\\''s MacBook Air";
    hostName = hostname;
    localHostName = hostname;
    search = ["lan"];
    knownNetworkServices = ["WiFi"];
  };
}
