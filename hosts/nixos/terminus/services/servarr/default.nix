{ ... }:
{
  imports = [
    ./jellyfin.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./sonarr.nix
  ];

  # Create the group for media stuff (jellyfin, sabnzbd, etc)
  users.groups.media = { };
}
