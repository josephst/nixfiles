{ config, pkgs, ... }: {
  age.secrets.hoarder.file = ../secrets/hoarder.env.age;

  virtualisation.oci-containers.containers = {
    hoarder-web = {
      image = "ghcr.io/hoarder-app/hoarder:release";
      autoStart = true;
      ports = [ "3000:3000" ];
      volumes = [
        "/var/lib/hoarder:/data"
      ];
      environmentFiles = [
        config.age.secrets.hoarder.path
      ];
      networks = [ "hoarder" ];
      environment = {
        "MEILI_ADDR" =  "http://meilisearch:7700";
        "BROWSER_WEB_URL" = "http://chrome:9222";
        # OPENAI_API_KEY = ...
        "DATA_DIR" = "/data";
      };
      dependsOn = [ "meilisearch" "chrome" ];
    };
    chrome = {
      image = "gcr.io/zenika-hub/alpine-chrome:latest";
      cmd = [
        "--no-sandbox"
        "--disable-gpu"
        "--disable-dev-shm-usage"
        "--remote-debugging-address=0.0.0.0"
        "--remote-debugging-port=9222"
        "--hide-scrollbars"
      ];
      networks = [ "hoarder" ];
    };
    meilisearch = {
      image = "getmeili/meilisearch:latest";
      environmentFiles = [
        config.age.secrets.hoarder.path
      ];
      environment = {
        "MEILI_NO_ANALYTICS" = "true";
      };
      volumes = [
        "/var/lib/meilisearch:/meili_data"
      ];
      networks = [ "hoarder" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hoarder - - - - -"
    "d /var/lib/meilisearch - - - - -"
  ];
}
