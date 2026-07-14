let
  josephLoginKeys = {
    Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air";
    nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQzdJLGBCLoOXdvJj6ab+9FovwCq+Y9tXalMzO+CC4x joseph@nixos-orbstack";
    terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5+7effMEZgBAWJeEqP9VD8m3ao1DuLNQk83HZ/TzrN joseph@terminus"; # terminus = home server
  };
  hostKeys = {
    Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4LUu5VYk6fVSjJoBXjvQc3VNTor4krhhezFg60/+iG root@Josephs-MacBook-Air";
    terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFVJX8U8YmJX/mhECofQHj/HDZhIKcV44KlVexhId3c root@nixos";
    nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL3m6s7bwvuODKtaS8C+DKKGxNkMyKaYoBQobT7bq8g root@nixos-orbstack";
    anacreon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzDY0AWcUfh8wgYNj8zxQoC0+hC9REZxQBsTInw+BD6 root@vps-1ab28197"; # OVH Cloud
  };
  josephAgeRecipients = josephLoginKeys // {
    # Used to decrypt the user's Home Manager secrets across all machines.
    agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrRmKWGnpr9wv6Rw5SyHXKPJwMqDS7pR3NHjlepBSxH agenix-home";

    # Used for rekeying secrets without exporting a key from 1Password each time.
    # This key only lives on the MacBook at ~/.config/agenix.
    agenix-rekeying = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2IChbPCqQBNdpguhGX+2kWqQlp8jkkTjhRrA3utx3v";
  };
in
{
  inherit hostKeys;

  # Only these keys grant SSH login. Use one key per user and machine.
  loginKeys.joseph = josephLoginKeys;

  # These keys can decrypt Agenix secrets, but are never installed as SSH
  # authorized keys. Login keys remain recipients so each machine can decrypt
  # secrets before the dedicated identity is available.
  ageRecipients.joseph = josephAgeRecipients;

  # Agenix recipient membership is centralized here so secret declarations
  # select a named purpose/host group rather than reconstructing key sets.
  recipientGroups = {
    joseph = builtins.attrValues josephAgeRecipients;
    fleet = builtins.attrValues josephAgeRecipients ++ builtins.attrValues hostKeys;
    anacreon = builtins.attrValues josephAgeRecipients ++ [ hostKeys.anacreon ];
  };

  # it does not matter which device the git commit is being signed by (more interested in which *user* is signing)
  signingKeys = {
    joseph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph-git-signing";
  };
}
