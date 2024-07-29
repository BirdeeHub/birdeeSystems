{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption mkMerge;
  bySystems = systems: f: (let
    genAttrs =
      names:
      f:
      builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
    nameValuePair =
      name:
      value:
      { inherit name value; };
  in
    genAttrs systems (system: f system));
  file = ./homeCFGperSystem.nix;
in
{
  _file = file;

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ system, config, ... }: {
      _file = file;

      options.homeCFGps = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
      };
    });
  };

  config = {
    flake.legacyPackages = bySystems config.systems (system: {
      homeConfigurations = (config.perSystem system).homeCFGps;
    });
  };
}
