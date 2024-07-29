{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
  inherit (import ./flake-utils.nix) bySystems;
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
