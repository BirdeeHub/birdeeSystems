inputs:
let
  wlib = inputs.wrappers.lib;
in
{
  lib,
  flake-parts-lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) types mkOption;
  file = ./wrapper.nix;
in
{
  _file = file;
  key = file;
  options = {
    flake = mkOption {
      type = types.submoduleWith {
        modules = [
          (
            { config, ... }:
            {
              _file = file;
              key = file;
              options.wrapperModules = mkOption {
                type = types.attrsOf types.raw;
                default = { };
                description = ''
                  contains unevaluated wrapper modules like from this library

                  https://github.com/BirdeeHub/nix-wrapper-modules
                '';
              };
              options.wrappedModules = mkOption {
                type = types.attrsOf types.raw;
                default = { };
                description = ''
                  contains partially evaluated wrapperModules
                '';
                apply = x: builtins.mapAttrs (_: v: (wlib.evalModule v).config) config.wrapperModules // x;
              };
            }
          )
        ];
      };
    };
    perSystem = flake-parts-lib.mkPerSystemOption (
      { system, pkgs, ... }:
      {
        _file = file;
        key = file;
        config.packages = builtins.mapAttrs (_: v: v.wrap { inherit pkgs; }) config.flake.wrappedModules;
      }
    );
  };

}
