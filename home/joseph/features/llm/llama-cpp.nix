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
  ] ++ lib.optional pkgs.stdenv.isLinux pkgs.python3Packages.huggingface-hub;
}
