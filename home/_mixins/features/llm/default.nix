{ pkgs
, lib
, hostname
, ...
}:
let
  installOn = [
    "terminus"
  ];
in lib.mkIf (builtins.elem hostname installOn) {
  home.packages = [
    # llm
    pkgs.llamaPackages.llama-cpp # from llama-cpp overlay
    pkgs.python3Packages.huggingface-hub
  ];
}
