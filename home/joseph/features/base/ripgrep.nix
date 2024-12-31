{ pkgs, ... }: {
  programs.ripgrep = {
    enable = true;
  };

  home.packages = with pkgs; [
    (writeShellScriptBin "fif" (builtins.readFile ../../bin/fif.sh))
  ];
}
