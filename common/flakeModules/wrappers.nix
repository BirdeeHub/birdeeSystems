{ inputs, util }:
let
  wlib = inputs.wrappers.lib;
in
{
  lib,
  flake-parts-lib,
  config,
  ...
}:
let
  inherit (lib) types mkOption;
  file = ./wrappers.nix;
in
{
  _file = file;
  key = file;
  options.flake = mkOption {
    type = types.submoduleWith {
      modules = [
        (
          { options, ... }:
          {
            _file = file;
            key = file;
            options.wrapperModules = mkOption {
              type = types.lazyAttrsOf types.deferredModule;
              readOnly = true;
              default = (types.lazyAttrsOf types.deferredModule).merge options.wrappers.loc options.wrappers.definitionsWithLocations;
              description = ''
                contains unevaluated wrapper modules like from this library

                https://github.com/BirdeeHub/nix-wrapper-modules
              '';
            };
            options.wrappers = mkOption {
              type = types.lazyAttrsOf (wlib.types.subWrapperModuleWith { });
              default = { };
              description = ''
                contains partially evaluated wrapperModules
              '';
            };
          }
        )
      ];
    };
  };
  options.perSystem =
    let
      wrapped = config.flake.wrappers;
    in
    flake-parts-lib.mkPerSystemOption (
      {
        pkgs,
        config,
        ...
      }:
      {
        _file = file;
        key = file;
        options.wrapperPkgs = mkOption {
          type = types.pkgs;
          default = pkgs;
        };
        config.packages = builtins.mapAttrs (_: v: v.wrap { pkgs = config.wrapperPkgs; }) wrapped;
      }
    );
}
