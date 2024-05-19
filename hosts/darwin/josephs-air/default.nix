{
  inputs,
  pkgs,
  config,
  ...
}:
let
  hostname = "Josephs-MacBook-Air";
in
{
  # machine-specific config
  imports = [ ./brew.nix ];

  networking = {
    # need to escape the single quote here
    # https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings
    computerName = "Joseph's MacBook Air";
    hostName = hostname;
    localHostName = hostname;
    search = [ "lan" ];
    knownNetworkServices = [ "WiFi" ];
  };

  myconfig.gui.enable = true;
  myconfig.llm.enable = true;
}
