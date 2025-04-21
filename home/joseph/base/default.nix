{ ... }:
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./bottom.nix # system viewer
    ./direnv.nix
    ./eza.nix # better ls
    ./fd.nix # better find
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./helix.nix
    ./nushell
    ./ssh.nix
    ./starship.nix
    ./wezterm
    ./zellij
  ];

  programs = {
    atuin = {
      enable = true;
      settings = {
        store_failed = true;
        sync = {
          records = true;
        };
      };
    };
    lazygit.enable = true;
    home-manager.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      settings = {
        autosu = true;
        diffgutter = true;
        paste = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
      };
    };
    ripgrep.enable = true;
    nix-index.enable = true;
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    zoxide.enable = true;
    zsh.enable = true;
  };
}
