{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption genAttrs;
  file = ./nixosCFGperSystem.nix;
in
{
  _file = file;

  options = {
    perSystem = flake-parts-lib.mkPerSystemOption {
      _file = file;

      options.nixosConfigurations = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
        description = ''
          perSystem.nixosConfigurations.<name> = legacyPackages.$${system}.nixosConfigurations.<name>
        '';
      };
    };
  };

  config = {
    flake.legacyPackages = genAttrs config.systems (system: {
      inherit (config.perSystem system) nixosConfigurations;
    });
  };
}
