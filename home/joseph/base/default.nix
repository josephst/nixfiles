{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
in
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
    ./ssh.nix
    ./starship.nix
    ./zellij
  ]
  ++ lib.optionals (!osConfig.hostSpec.isMinimal) [
    ./bun.nix
    ./nushell
  ];

  age.secrets."1password-serviceacct.env" = {
    file = ../secrets/1pass.env.age;
  };
  age.secrets."1password-serviceacct-fish" = {
    # same contents as above, but without the `OP_SERVICE_ACCOUNT_TOKEN` part
    # fish doesn't want an ENV file, it just wants the string
    file = ../secrets/1pass.age;
  };

  home.packages =
    with pkgs;
    [
      age # encryption
      agenix # age secrets
      bc # calculator
      comma # run commands by prefacing with comma
      cpufetch # CPU info
      cyme # modern lsusb

      doggo # better dig
      dua # modern du
      duf # modern df
      fd # find
      git-credential-manager
      ipfetch # IP info
      just # command runner
      ncdu # TUI disk usage
      nixd # Nix LSP
      nixfmt # nix formatter
      nixpkgs-hammering # nixpkgs linter
      nixpkgs-review # review PRs
      nix-prefetch-scripts # nix code fetcher
      nix-update # update nixpkgs
      nurl # nix url fetcher
      procs # modern ps
      rclone # syncing
      restic # backup
      rsync # syncing
    ]
    ++ lib.optionals (!osConfig.hostSpec.isMinimal) [
      bun # nodejs alternative
      delta # git and diff viewer
      diffsitter # better diff
      glow # markdown on terminal
      httpie # better curl
      hugo # static website builder
      hyperfine # command-line benchmarking
      lazygit # git with TUI
      magic-wormhole
      speedtest-go # speedtest CLI
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          pyyaml
        ]
      )) # python
      tealdeer # cheatsheets in terminal
      stable.yt-dlp # youtube-dl
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
  ]
  ++ lib.optional config.programs.npm.enable "$HOME/.npm/bin";

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
    fish = {
      enable = true;
      interactiveShellInit = ''
        # source 1password-cli plugins
        if test -e ~/.config/op/plugins.sh
          source ~/.config/op/plugins.sh
        end

        set -x SHELL ${pkgs.fish}/bin/fish
      ''
      + lib.optionalString osConfig.hostSpec.isServer ''
        set -x OP_SERVICE_ACCOUNT_TOKEN $(cat $XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish)
      '';
    };
    gh = {
      enable = true;
      extensions = [ ];
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    home-manager.enable = true;
    jq.enable = true;
    lazygit.enable = true;
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
    nix-index.enable = true;
    npm.enable = !osConfig.hostSpec.isMinimal;
    ripgrep.enable = true;
    uv = lib.mkIf (!osConfig.hostSpec.isMinimal) {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system"; # let Nix manage python install
      };
    };
    yazi = lib.mkIf (!osConfig.hostSpec.isMinimal) {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      shellWrapperName = "y";
    };
    zoxide.enable = true;
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      initContent = ''
        # source 1password-cli plugins
        if test -e ~/.config/op/plugins.sh; then
          source ~/.config/op/plugins.sh
        fi

        # Added by OrbStack: command-line tools and integration
        source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      '';
    };
  };
}
