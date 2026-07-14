{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  isMinimal = osConfig.hostSpec.cliProfile == "minimal";
in
{
  programs = {
    atuin = {
      enable = true;
      settings = {
        store_failed = true;
        sync.records = true;
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
