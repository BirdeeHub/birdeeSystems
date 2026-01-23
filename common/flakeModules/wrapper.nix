{ inputs, util }:
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
                type = types.lazyAttrsOf types.deferredModule;
                default = { };
                description = ''
                  contains unevaluated wrapper modules like from this library

                  https://github.com/BirdeeHub/nix-wrapper-modules
                '';
              };
              options.wrappedModules = mkOption {
                type = types.lazyAttrsOf (wlib.types.subWrapperModuleWith { });
                description = ''
                  contains partially evaluated wrapperModules
                '';
              };
              config.wrappedModules = config.wrapperModules;
            }
          )
        ];
      };
    };
    perSystem =
      let
        wrapped = config.flake.wrappedModules;
      in
      flake-parts-lib.mkPerSystemOption (
        {
          system,
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
  };
  config.flake.modules.generic = config.flake.wrapperModules;
  config.flake.modules.homeManager = builtins.mapAttrs (
    n: v:
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.wrapperModules.${n} = lib.mkOption {
        default = { };
        type = wlib.types.subWrapperModule [
          v
          {
            config.pkgs = pkgs;
            options.enable = lib.mkEnableOption n;
          }
        ];
      };
      config.home.packages = lib.mkIf config.wrapperModules.${n}.enable [
        config.wrapperModules.${n}.wrapper
      ];
    }
  ) config.flake.wrapperModules;
  config.flake.modules.nixos = builtins.mapAttrs (
    n: v:
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.wrapperModules.${n} = lib.mkOption {
        default = { };
        type = wlib.types.subWrapperModule [
          v
          {
            config.pkgs = pkgs;
            options.enable = lib.mkEnableOption n;
          }
        ];
      };
      config.environment.systemPackages = lib.mkIf config.wrapperModules.${n}.enable [
        config.wrapperModules.${n}.wrapper
      ];
    }
  ) config.flake.wrapperModules;
}
