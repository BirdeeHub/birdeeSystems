{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption genAttrs;
  file = ./homeCFGperSystem.nix;
in
{
  _file = file;

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption {
      _file = file;

      options.homeConfigurations = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
      };
    };
  };

  config = {
    flake.legacyPackages = genAttrs config.systems (system: {
      inherit (config.perSystem system) homeConfigurations;
    });
  };
}
