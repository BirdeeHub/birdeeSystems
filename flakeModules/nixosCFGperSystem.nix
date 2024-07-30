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
          `perSystem.nixosConfigurations.<name> = flake.legacyPackages.$${system}.nixosConfigurations.<name>`
          Warning: will conflict with existing `flake.legacyPackages.$${system}.nixosConfigurations.<name>` definitions
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
