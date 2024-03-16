{ secrets, ... }:
{
  # may need to run `nix flake update` and `nixos-rebuild` commands
  # with `--option access-tokens github.com=ghp_XXXXXXXXXXXXX` at first
  age.secrets.ghToken = {
    file = "${secrets}/ghToken.age";
    mode = "0440";
  };
}
