{ pkgs, config, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  imports = [
    ./bash.nix
    ./bat.nix
    ./bottom.nix # system viewer
    ./bun.nix
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

  home.packages =
    with pkgs;
    [
      age # encryption
      agenix # age secrets
      bc # calculator
      # claude-code # claude code # install w/ NPM or bun
      comma # run commands by prefacing with comma
      cpufetch # CPU info
      cyme # modern lsusb
      delta # git and diff viewer
      diffsitter # better diff
      doggo # better dig
      dua # modern du
      duf # modern df
      fd # find
      httpie # better curl
      hub # Git wrapper that has better Github support
      hugo # static website builder
      hyperfine # command-line benchmarking
      ipfetch # IP info
      just # command runner
      lazygit # git with TUI
      llama-cpp # local LLM
      magic-wormhole
      marp-cli # markdown presentation
      ncdu # TUI disk usage
      nodejs
      nixd # Nix LSP
      nixfmt # nix formatter
      nixpkgs-hammering # nixpkgs linter
      nixpkgs-review # review PRs
      nix-prefetch-scripts # nix code fetcher
      nix-update # update nixpkgs
      nurl # nix url fetcher
      procs # modern ps
      speedtest-go # speedtest CLI
      python3 # python
      python3Packages.huggingface-hub
      rclone # syncing
      restic # backup
      rsync # syncing
      tealdeer # cheatsheets in terminal
      typst # latex alternative for typesetting docs
      yt-dlp # youtube-dl
    ]
    ++ lib.optionals isLinux [
      iw # terminal wifi info
      pciutils # PCI info
      s-tui # stress test
      usbutils # USB info
    ]
    ++ lib.optionals isDarwin [
      nh # nix client (on nixos, this is a module)
      coreutils # macOS coreutils
    ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs = {
    atuin = {
      enable = true;
      # Don't enable fish integration, but do it manually in fish.interactiveShellInit
      # because the default binding for up causes https://github.com/atuinsh/atuin/issues/2803
      enableFishIntegration = false;
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
    uv = {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system"; # let Nix manage python install
      };
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    zoxide.enable = true;
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
    };
  };
}
