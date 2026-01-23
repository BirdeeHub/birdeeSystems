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
  installMods = builtins.mapAttrs (name: value: {
    inherit name value;
    __functor = util.mkInstallModule;
  }) config.flake.wrapperModules;
in
{
  _file = file;
  key = file;
  imports = [ inputs.flake-parts.flakeModules.modules ];
  options.flake = mkOption {
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
            options.wrappers = mkOption {
              type = types.lazyAttrsOf (wlib.types.subWrapperModuleWith { });
              description = ''
                contains partially evaluated wrapperModules
              '';
            };
            config.wrappers = config.wrapperModules;
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
  config.flake.modules.homeManager = builtins.mapAttrs (
    _: v:
    v
    // {
      loc = [
        "home"
        "packages"
      ];
    }
  ) installMods;
  config.flake.modules.nixos = installMods;
  config.flake.modules.darwin = installMods;
  config.flake.modules.generic = config.flake.wrapperModules // {
    default = {
      imports = builtins.attrValues installMods;
    };
  };
}
