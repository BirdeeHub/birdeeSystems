# TODO: make yourself a dendritic hm module eventually
{
  lib,
  flake-parts-lib,
  config,
  inputs,
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
        type = types.attrsOf (
          types.submodule (
            { config, name, ... }:
            {
              options = {
                home-manager = mkOption {
                  type = types.raw;
                  default = inputs.home-manager;
                };
                pkgs = mkOption {
                  type = types.raw;
                  default = config.pkgs;
                };
                lib = mkOption {
                  type = types.attrsOf types.raw;
                  default = config.pkgs.lib;
                };
                extraSpecialArgs = mkOption {
                  type = types.attrsOf types.raw;
                  default = { };
                };
                config = mkOption {
                  type = types.deferredModule;
                  default = { };
                };
                modules = mkOption {
                  type = types.listOf types.raw;
                  default = [ ];
                  apply = x: [
                    (
                      { pkgs, ... }:
                      {
                        nix.package = pkgs.nix;
                      }
                    )
                    config.config
                  ] ++ x;
                };
                check = mkOption {
                  type = types.bool;
                  default = true;
                };
                minimal = mkOption {
                  type = types.bool;
                  default = false;
                };
              };
            }
          )
        );
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
      homeConfigurations = builtins.mapAttrs (n: v: v.home-manager.lib.homeManagerConfiguration (builtins.removeAttrs v [ "home-manager" "config" ])) (config.perSystem system).homeConfigurations;
    });
  };
}
