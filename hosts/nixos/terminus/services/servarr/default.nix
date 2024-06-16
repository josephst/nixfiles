{ ... }:
{
  imports = [
    ./plex.nix
    ./prowlarr.nix
    ./radarr.nix
    ./servarr.nix
    ./sonarr.nix
  ];

  # Create the group for media stuff (plex, sabnzbd, etc)
  users.groups.media = { };
}
