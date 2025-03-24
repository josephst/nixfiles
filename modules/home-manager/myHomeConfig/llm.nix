{ config, lib, pkgs, ... }:

let
  cfg = config.myHomeConfig.llm;
in
{
  options.myHomeConfig.llm.enable = lib.mkEnableOption "LLM support";

  config = lib.mkIf cfg.enable {
    home.packages = [
      # llm
      pkgs.llamaPackages.llama-cpp # from llama-cpp overlay
      pkgs.python3Packages.huggingface-hub
    ];
  };
}
