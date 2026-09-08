{
  config,
  ...
}:
{
  age.secrets = {
    "recyclarr/sonarr-api-key".file = ../../secrets/recyclarr/sonarr-api-key.age;
    "recyclarr/radarr-api-key".file = ../../secrets/recyclarr/radarr-api-key.age;
  };
  services.recyclarr = {
    enable = true;
    configuration = {
      sonarr = {
        mySonarr = {
          base_url = "http://localhost:8989";
          api_key = {
            _secret = config.age.secrets."recyclarr/sonarr-api-key".path;
          };

          delete_old_custom_formats = true;
          # Guide-backed profiles replace the retired include templates (Recyclarr v8).
          # https://recyclarr.dev/guide/guide-configs/
          # Series size limits apply instance-wide.
          quality_definition.type = "series";
          media_naming = {
            series = "default";
            season = "default";
            episodes = {
              rename = true;
              standard = "default";
              daily = "default";
            };
          };
          quality_profiles = [
            {
              name = "WEB-1080p";
              trash_id = "72dae194fc92bf828f32cde7744e51a1";
              reset_unmatched_scores.enabled = true;
            }
          ];
          # Default groups sync automatically; add the WEB profile codec/language groups.
          custom_format_groups.add = [
            {
              trash_id = "158188097a58d7687dee647e04af0da3"; # Golden Rule HD
              assign_scores_to = [ { name = "WEB-1080p"; } ];
            }
            {
              trash_id = "74aff4168620ed49dcc67e92b2c2a5b4"; # Language Profiles
              assign_scores_to = [ { name = "WEB-1080p"; } ];
            }
          ];
        };
      };
      radarr = {
        myRadarr = {
          base_url = "http://localhost:7878";
          api_key = {
            _secret = config.age.secrets."recyclarr/radarr-api-key".path;
          };

          delete_old_custom_formats = true;
          # Movie size limits remain shared by both profiles.
          quality_definition.type = "movie";
          media_naming = {
            folder = "default";
            movie = {
              rename = true;
              standard = "standard";
            };
          };
          quality_profiles = [
            {
              name = "UHD Bluray + WEB";
              trash_id = "64fb5f9858489bdac2af690e27c8f42f";
              reset_unmatched_scores.enabled = true;
            }
            {
              name = "HD Bluray + WEB";
              trash_id = "d1d67249d3890e49bc12e275d989a7e9";
              reset_unmatched_scores.enabled = true;
            }
          ];
          # Guide-backed profiles supply their default CF groups and scores.
          # Keep the existing optional preferences on both movie profiles.
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

  systemd.services.recyclarr = {
    requires = [
      "radarr.service"
      "sonarr.service"
    ];
    after = [
      "radarr.service"
      "sonarr.service"
    ];
  };
}
