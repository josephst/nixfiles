{
  hosts = {
    Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4LUu5VYk6fVSjJoBXjvQc3VNTor4krhhezFg60/+iG root@Josephs-MacBook-Air";
    terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFVJX8U8YmJX/mhECofQHj/HDZhIKcV44KlVexhId3c root@nixos";
    nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBL3m6s7bwvuODKtaS8C+DKKGxNkMyKaYoBQobT7bq8g root@nixos-orbstack";
    vmware = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbWFKhqRA+BmjoowgmjZHnwRibmKW/AZJBueW4F7cpi root@nixos";
  };

  users = {
    # recommended to have one key per user, per machine
    joseph = {
      # agenix: special key which is used to decrypt user's $HOME across all machines (including before a machine-specific key is set up)
      agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrRmKWGnpr9wv6Rw5SyHXKPJwMqDS7pR3NHjlepBSxH agenix-home";

      Josephs-MacBook-Air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuLA4wwwupvYW3UJTgOtcOUHwpmRR9gy/N+F6n11d5v joseph@macbook-air";
      nixos-orbstack = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQzdJLGBCLoOXdvJj6ab+9FovwCq+Y9tXalMzO+CC4x joseph@nixos-orbstack";
      terminus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5+7effMEZgBAWJeEqP9VD8m3ao1DuLNQk83HZ/TzrN joseph@terminus"; # terminus = home server
      vmware = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCYQoSo3TdxLk4Augirkcbqefx2QQHh/543GDYfMODx joseph@vmware";
    };
  };

  # it does not matter which device the git commit is being signed by (more interested in which *user* is signing)
  signing = {
    joseph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxKQtKkR7jkse0KMDvVZvwvNwT0gUkQ7At7Mcs9GEop joseph-git-signing";
  };
}
