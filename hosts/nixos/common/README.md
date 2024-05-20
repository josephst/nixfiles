# Common NixOS modules

## `default.nix` - a sane NixOS setup for both GUI-enabled and headless systems.
`default.nix` is the default module, imported in `flake.nix` for most systems

## `server.nix` - a customized setup specific for headless servers
`server.nix` applies a few additional server-specific options meant for headless servers.
It can be paired with some mixins, such as `../mixins/cloudinit.nix`, as needed.