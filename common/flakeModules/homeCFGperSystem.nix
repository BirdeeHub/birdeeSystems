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
        description = ''
          `perSystem.homeConfigurations.<name> = flake.legacyPackages.$${system}.homeConfigurations.<name>`
          Warning: will conflict with existing `flake.legacyPackages.$${system}.homeConfigurations.<name>` definitions
        '';
      };
    };
  };

  config = {
    flake.legacyPackages = genAttrs config.systems (system: {
      inherit (config.perSystem system) homeConfigurations;
    });
  };
}
