{
  config,
  ...
}:
{
  age.secrets.recyclarrApiKeys = {
    file = ../../secrets/recyclarrApiKeys.yaml.age;
  };

  services.recyclarr = {
    enable = true;
    secretsFile = config.age.secrets.recyclarrApiKeys.path;

    configuration = {
      sonarr = {
        mySonarr = {
          base_url = "http://localhost:8989";
          api_key = "!secret sonarr_api_key";

          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          include = [
            # Series
            { template = "sonarr-quality-definition-series"; }
            # 4k
            # { template = "sonarr-v4-quality-profile-web-2160p"; }
            # { template = "sonarr-v4-custom-formats-web-2160p"; }
            # 1080p
            { template = "sonarr-v4-quality-profile-web-1080p"; }
            { template = "sonarr-v4-custom-formats-web-1080p"; }
            # Anime
            { template = "sonarr-quality-definition-anime"; }
            { template = "sonarr-v4-quality-profile-anime"; }
            { template = "sonarr-v4-custom-formats-anime"; }
          ];
        };
      };
      radarr = {
        myRadarr = {
          base_url = "http://localhost:7878";
          api_key = "!secret radarr_api_key";

          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          include = [
            # Movies
            { template = "radarr-quality-definition-movie"; }
            # 4k
            # { template = "radarr-quality-profile-remux-web-2160p"; }
            # { template = "radarr-custom-formats-remux-web-2160p"; }
            { template = "radarr-quality-profile-uhd-bluray-web"; }
            { template = "radarr-custom-formats-uhd-bluray-web"; }
            # 1080p
            # { template = "radarr-quality-profile-remux-web-1080p"; }
            # { template = "radarr-custom-formats-remux-web-1080p"; }
            { template = "radarr-quality-profile-hd-bluray-web"; }
            { template = "radarr-custom-formats-hd-bluray-web"; }
            # Anime
            { template = "radarr-quality-profile-anime"; }
            { template = "radarr-custom-formats-anime"; }
          ];
          custom_formats = [
            # preferred formats
            {
              trash_ids = [
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
              ];
              assign_scores_to = [
                { name = "HD Bluray + WEB"; }
                { name = "UHD Bluray + WEB"; }
              ];
            }
            # dispreferred formats
            {
              trash_ids = [
                "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
                "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
                "f537cf427b64c38c8e36298f657e4828" # Scene
              ];
              assign_scores_to = [
                { name = "HD Bluray + WEB"; }
                { name = "UHD Bluray + WEB"; }
              ];
            }
          ];
        };
      };
    };
  };
}
