{ pkgs, config, ... }:
let
  aiderConf = "${config.xdg.configHome}/aider/aider.conf.yml";
  aider = pkgs.aider-chat.overrideAttrs (
    final: prev: {
      makeWrapperArgs = (prev.makeWrapperArgs or [ ]) ++ [
        ''--add-flags "--config ${aiderConf}"''
      ];
    }
  );
in
{
  # TODO: perhaps make this a shellAbbr instead of overriding the package?
  # slows down builds to re-package aider
  home.packages = [ aider ];

  age.secrets."aider.conf.yml" = {
    file = ../../secrets/aider.conf.yml.age;
    path = aiderConf;
  };

  programs.git.ignores = [ ".aider*" ];
}
