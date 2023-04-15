{
  config,
  lib,
  pkgs,
  ...
}:
# based on https://github.com/LongerHV/nixos-configuration/blob/f4d51a14753f9998b4585d6db525b12ec8e62a7b/modules/nixos/dashy.nix
# by LongerHV
let
  cfg = config.services.dashy;
  format = pkgs.formats.yaml {};
  configFile = format.generate "conf.yml" cfg.settings;
in {
  options.services.dashy = with lib; {
    enable = mkEnableOption "dashy";
    imageTag = mkOption {
      type = types.str;
    };
    # package = mkOption {
    #   type = types.package;
    #   default = pkgs.dashy;
    # };
    port = mkOption {
      type = types.int;
      default = 4000;
    };
    # user = mkOption {
    #   type = types.str;
    #   default = "dashy";
    # };
    # group = mkOption {
    #   type = types.str;
    #   default = "dashy";
    # };
    # dataDir = mkOption {
    #   type = types.path;
    #   default = "/var/lib/dashy";
    # };
    # mutableConfig = mkOption {
    #   type = types.bool;
    #   default = false;
    # };
    settings = mkOption {
      type = types.attrs;
      default = {};
    };

    extraOptions = mkOption {};
  };

  config = lib.mkIf cfg.enable {
    # users.users."${cfg.user}" = {
    #   inherit (cfg) group;
    #   isSystemUser = true;
    #   home = cfg.dataDir;
    #   createHome = true;
    # };
    # users.groups."${cfg.group}" = { };
    virtualisation.oci-containers.containers = {
      dashy = {
        autoStart = true;
        ports = ["4000:80"]; # server port : docker port
        image = "lissy93/dashy:${cfg.imageTag}";
        inherit (cfg) extraOptions;
        environment = {
          TZ = "${config.time.timeZone}";
        };
        volumes = [
          "${configFile}:/app/public/conf.yml"
        ];
      };
    };

    # systemd.services.dashy = {
    #   after = [ "network-online.target" ];
    #   wantedBy = [ "multi-user.target" ];
    #   preStart = ''
    #     mkdir -p ${cfg.dataDir}/public
    #   '' + (if cfg.mutableConfig then ''
    #     if [ ! -f ${cfg.dataDir}/public/conf.yml ]; then
    #       cp ${cfg.package}/share/dashy/public/conf.yml ${cfg.dataDir}/public/conf.yml
    #       chmod u+w ${cfg.dataDir}/public/conf.yml
    #     fi
    #   '' else ''
    #     ln -sf ${configFile} ${cfg.dataDir}/public/conf.yml
    #   '');
    #   serviceConfig = {
    #     ExecStart = "${cfg.package}/bin/dashy";
    #     WorkingDirectory = cfg.dataDir;
    #     User = cfg.user;
    #     Group = cfg.group;
    #     Restart = "always";
    #   };
    #   environment = {
    #     PORT = builtins.toString cfg.port;
    #   };
    # };
  };
}
