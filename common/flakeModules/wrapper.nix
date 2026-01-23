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
  inherit (lib) types mkOption toList;
  file = ./wrapper.nix;
  mkInstallModule =
    optionName: module:
    let
      default-optloc = [ "wrapperModules" ];
      default-loc = [
        "environment"
        "systemPackages"
      ];
    in
    {
      optloc = default-optloc;
      loc = default-loc;
      name = optionName;
      __functor =
        {
          optloc ? default-optloc,
          loc ? default-loc,
          name ? optionName,
          ...
        }:
        {
          pkgs,
          lib,
          config,
          ...
        }:
        {
          options = lib.setAttrByPath (optloc ++ [ name ]) (
            lib.mkOption {
              default = { };
              type = wlib.types.subWrapperModule (
                (toList module)
                ++ [
                  {
                    config.pkgs = pkgs;
                    options.enable = lib.mkEnableOption name;
                  }
                ]
              );
            }
          );
          config = lib.setAttrByPath loc (
            lib.mkIf
              (lib.getAttrFromPath (
                optloc
                ++ [
                  name
                  "enable"
                ]
              ) config)
              [
                (lib.getAttrFromPath (
                  optloc
                  ++ [
                    name
                    "wrapper"
                  ]
                ) config)
              ]
          );
        };
    };
  installMods = builtins.mapAttrs mkInstallModule config.flake.wrapperModules;
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
  options.perSystem =
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
