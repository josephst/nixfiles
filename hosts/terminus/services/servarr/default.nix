{ ... }:
{
  imports = [
    ./plex.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./sonarr.nix
  ];

  # Create the group for media stuff (plex, sabnzbd, etc)
  users.groups.media = { };
}
