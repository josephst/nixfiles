{ osConfig, ... }:
{
  programs.nushell = {
    enable = osConfig.hostSpec.cliProfile != "minimal";
    loadSessionVariables = true;
  };
}
