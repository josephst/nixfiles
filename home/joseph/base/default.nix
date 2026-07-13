{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  isMinimal = osConfig.hostSpec.cliProfile == "minimal";
  isServer = osConfig.hostSpec.role == "server";
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
    ./ssh.nix
    ./starship.nix
  ]
  ++ lib.optionals (!isMinimal) [
    ./nushell
    ./zellij
  ];

  age.secrets = lib.mkIf isServer {
    "1password-serviceacct.env".file = ../secrets/1pass.env.age;
    # Same value as above without the OP_SERVICE_ACCOUNT_TOKEN assignment;
    # Fish consumes the token rather than an environment file.
    "1password-serviceacct-fish".file = ../secrets/1pass.age;
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
    ++ lib.optionals (!isMinimal) [
      diffsitter # better diff
      glow # markdown on terminal
      httpie # better curl
      hugo # static website builder
      hyperfine # command-line benchmarking
      magic-wormhole
      speedtest-go # speedtest CLI
      (python3.withPackages (
        python-pkgs: with python-pkgs; [
          pyyaml
        ]
      )) # python
      tealdeer # cheatsheets in terminal
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

  home.sessionPath = lib.optional config.programs.npm.enable "$HOME/.npm/bin";

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
    fish = {
      enable = true;
      interactiveShellInit = ''
        # source 1password-cli plugins
        if test -e ~/.config/op/plugins.sh
          source ~/.config/op/plugins.sh
        end

        set -x SHELL ${pkgs.fish}/bin/fish
      ''
      + lib.optionalString isServer ''
        if test -r "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish"
          set -x OP_SERVICE_ACCOUNT_TOKEN (${pkgs.coreutils}/bin/cat "$XDG_RUNTIME_DIR/agenix/1password-serviceacct-fish")
        end
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
    npm.enable = true; # installs NPM and Node.js
    ripgrep.enable = true;
    uv = lib.mkIf (!isMinimal) {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system"; # let Nix manage python install
      };
    };
    yazi = lib.mkIf (!isMinimal) {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      shellWrapperName = "y";
    };
    zoxide.enable = true;
    zsh = {
      enable = true;
      initContent =
        let
          zshConfigEarlyInit = lib.mkBefore ''
            if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
              zmodload zsh/zprof
            fi
          '';
          zshConfigLate = lib.mkAfter ''
            if [[ -n "$ZSH_PROFILE_STARTUP" ]]; then
              zprof
            fi
          '';

          zshConfig = ''
            # source 1password-cli plugins
            if test -e ~/.config/op/plugins.sh; then
              source ~/.config/op/plugins.sh
            fi

            # Added by OrbStack: command-line tools and integration
            source ~/.orbstack/shell/init.zsh 2>/dev/null || :
          '';
        in
        lib.mkMerge [
          zshConfigEarlyInit
          zshConfig
          zshConfigLate
        ];
    };
  };
}
