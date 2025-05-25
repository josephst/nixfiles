{
  outputs,
  config,
  lib,
  ...
}:
{
  options.myConfig.nixpkgs = with lib; {
    overlays = mkOption {
      type = types.listOf types.unspecified;
      default = builtins.attrValues outputs.overlays;
      description = "Overlays to apply to nixpkgs";
    };

    allowUnfree = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow unfree packages";
    };
  };

  config = {
    nixpkgs = {
      hostPlatform = config.myConfig.platform;
      inherit (config.myConfig.nixpkgs) overlays;
      config = {
        inherit (config.myConfig.nixpkgs) allowUnfree;
      };
    };
  };
}
