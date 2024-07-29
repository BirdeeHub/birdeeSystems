{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
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
  file = ./nixosCFGperSystem.nix;
in
{
  _file = file;

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ system, config, ... }: {
      _file = file;

      options.nixosConfigurations = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
      };
    });
  };

  config = {
    flake.legacyPackages = bySystems config.systems (system: {
      inherit (config.perSystem system) nixosConfigurations;
    });
  };
}
