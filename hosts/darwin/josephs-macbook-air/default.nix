_:
let
  hostname = "Josephs-MacBook-Air";
in
{
  # machine-specific config
  imports = [
    ./brew.nix
  ];

  networking = {
    # need to escape the single quote here
    # https://stackoverflow.com/questions/1250079/how-to-escape-single-quotes-within-single-quoted-strings
    computerName = "Joseph's MacBook Air";
    hostName = hostname;
    localHostName = hostname;
    search = [ "lan" ];
    knownNetworkServices = [ "WiFi" ];
  };

  nixpkgs.hostPlatform = {
    system = "aarch64-darwin";
  };

  services.openssh.enable = false; # TODO: delete once https://github.com/ryantm/agenix/pull/307 merged

  # TODO: delete this section?
  myconfig.gui.enable = true;
  myconfig.llm.enable = true;
}
