{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.packages = lib.optionals osConfig.myconfig.llm.enable [
    # llm
    pkgs.llamaPackages.llama-cpp # from llama-cpp overlay
    pkgs.python3Packages.huggingface-hub
  ];
}
