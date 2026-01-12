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
  file = ./overlay.nix;
in
{
  _file = file;
  key = file;
  options = {
    flake = mkOption {
      type = types.submoduleWith {
        modules = [
          {
            _file = file;
            key = file;
            options.overlist = mkOption {
              type = lib.types.listOf types.raw;
              readOnly = true;
              default = wlib.dag.sortAndUnwrap {
                dag = config.overlays;
                name = "overlays";
                mapIfOk = v: v.data;
              };
            };
            config.overlays = lib.filterAttrs (_: v: v != null) (
              builtins.mapAttrs (n: v: if v.enable then v.data else null) config.overlays
            );
          }
        ];
      };
    };
    overlays = mkOption {
      type = types.lazyAttrsOf (
        wlib.types.spec [
          (wlib.dag.mkDagEntry {
            dataOptFn =
              { name, config, ... }:
              {
                type = types.raw;
                apply = x: if config.call-data-with-name then x name else x;
              };
          })
          {
            options = {
              enable = mkOption {
                default = true;
                type = types.bool;
              };
              call-data-with-name = mkOption {
                default = false;
                type = types.bool;
              };
            };
          }
        ]
      );
      default = { };
    };
  };
}
