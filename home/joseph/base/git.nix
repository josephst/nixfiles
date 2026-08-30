{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  gitSigningKey = osConfig.myConfig.keys.signingKeys.${config.home.username} or null;
  localSigningKey =
    osConfig.myConfig.keys.loginKeys.${config.home.username}.${osConfig.networking.hostName} or null;
  useLocalSigningFallback =
    isLinux && osConfig.networking.hostName == "terminus" && localSigningKey != null;
  localSigningKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  forwardedSigningKeyFile = pkgs.writeText "git-signing.pub" "${gitSigningKey}\n";

  # Git uses the local key by default so it never performs its own agent lookup
  # before invoking the signer. The signer substitutes the user signing key
  # when it is present in a genuinely forwarded agent, while avoiding the
  # desktop's 1Password agent for unattended local processes such as Codex.
  gitSshSigner = pkgs.writeShellApplication {
    name = "git-ssh-sign";
    runtimeInputs = [ pkgs.openssh ];
    text = ''
      is_signing=false
      for arg in "$@"; do
        if [[ "$arg" == "sign" ]]; then
          is_signing=true
          break
        fi
      done

      if [[ "$is_signing" != true ]]; then
        exec ssh-keygen "$@"
      fi

      args=("$@")
      signing_key_index=-1
      for ((i = 0; i < ''${#args[@]} - 1; i++)); do
        if [[ "''${args[$i]}" == "-f" ]]; then
          signing_key_index=$((i + 1))
          break
        fi
      done

      if ((signing_key_index < 0)); then
        echo "git-ssh-sign: ssh-keygen invocation did not include a signing key" >&2
        exit 1
      fi

      agent_is_forwarded=false
      if [[ -n "''${SSH_CONNECTION:-}" && -S "''${SSH_AUTH_SOCK:-}" ]]; then
        case "$SSH_AUTH_SOCK" in
          ${lib.escapeShellArg "${config.home.homeDirectory}/.1password/agent.sock"}|*/.codex/app-server-control/forwarded-ssh-agent.sock) ;;
          *) agent_is_forwarded=true ;;
        esac
      fi

      if [[ "$agent_is_forwarded" == true ]]; then
        forwarded_key_available=false
        while read -r key_type key_data _; do
          if [[ "$key_type $key_data" == ${lib.escapeShellArg (lib.concatStringsSep " " (lib.take 2 (lib.splitString " " gitSigningKey)))} ]]; then
            forwarded_key_available=true
            break
          fi
        done < <(ssh-add -L 2>/dev/null)

        if [[ "$forwarded_key_available" == true ]]; then
          args[signing_key_index]=${lib.escapeShellArg forwardedSigningKeyFile}
          exec ssh-keygen "''${args[@]}"
        fi
      fi

      if [[ ! -r ${lib.escapeShellArg localSigningKeyPath} ]]; then
        echo "git-ssh-sign: local signing key is not readable: ${localSigningKeyPath}" >&2
        exit 1
      fi

      exec ssh-keygen "$@"
    '';
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "1269177+josephst@users.noreply.github.com";
        name = "Joseph Stahl";
      };
      aliases = {
        l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        p = "pull --ff-only";
        ff = "merge --ff-only";
        graph = "log --decorate --oneline --graph";
        pushall = "!git remote | xargs -L1 git push --all";
        undo = "reset HEAD~1 --mixed";
        add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
      };
      gpg = {
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };
      github.user = "josephst";
      credential.helper = lib.mkIf isDarwin "manager";
      init.defaultBranch = "main";
      # Automatically track remote branch
      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      pull = {
        rebase = true;
      };
      branch.sort = "-committerdate";
      # delta options
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
      diff = {
        colorMoved = "plain";
        algorithm = "histogram";
        renames = "true";
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      help.autocorrect = "prompt";
    };
    signing = {
      signByDefault = gitSigningKey != null;
      format = "ssh";
      signer =
        if isDarwin then
          "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          lib.mkIf useLocalSigningFallback "${gitSshSigner}/bin/git-ssh-sign";
      # https://git-scm.com/docs/git-config#Documentation/git-config.txt-usersigningKey
      key =
        if useLocalSigningFallback then
          localSigningKeyPath
        else
          lib.mkIf (gitSigningKey != null) "key::${gitSigningKey}";
    };
    ignores = [
      # Compiled Python files
      "*.pyc"

      # Folder view configuration files
      ".DS_Store"
      "Desktop.ini"

      # Thumbnail cache files
      "._*"
      "Thumbs.db"

      # Files that might appear on external disks
      ".Spotlight-V100.Trashes"

      # Nix-specific
      ".devenv"
      ".direnv"
    ];
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
