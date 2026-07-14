{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  gitSigningKey =
    if osConfig.myConfig.keys != null && lib.hasAttr "joseph" osConfig.myConfig.keys.signingKeys then
      lib.getAttr "joseph" osConfig.myConfig.keys.signingKeys
    else
      null;
in
{
  imports = [
    ../common
    ./base
    ./darwin.nix
    ./linux.nix
  ];

  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      EDITOR = "hx";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      MANROFFOPT = "-c";
      VISUAL = "hx";
      SUDO_EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
    };
    shellAliases = {
      dig = "doggo";
      copy = "rsync --archive --verbose --human-readable --partial --progress --modify-window=1"; # copy <source> <destination>
      external-ip = "doggo +short myip.opendns.com @resolver1.opendns.com";
    };

    file = {
      ".agents/skills/.keep".text = "";
      "dev/.keep".text = "";

      # link nixpkgs-manual for quick reference
      "Documents/nixpkgs-manual.html".source = "${pkgs.nixpkgs-manual}/share/doc/nixpkgs/manual.html";

      ".ssh/allowed_signers" =
        lib.mkIf (gitSigningKey != null && config.programs.git.settings.user.email != null)
          {
            text = "${config.programs.git.settings.user.email} ${gitSigningKey}";
          };
    };
  };

}
