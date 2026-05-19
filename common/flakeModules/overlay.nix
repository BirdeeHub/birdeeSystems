{ inputs, util, ... }@args:
{
  lib,
  flake-parts-lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) types mkOption;
  file = ./overlay.nix;
  overlayType = lib.mkOptionType {
    name = "overlay";
    description = "overlay";
    descriptionClass = "noun";
    check = builtins.isFunction;
    merge = loc:
      lib.flip lib.pipe [
        (map (v: v // { value = [ v.value ]; }))
        ((types.listOf lib.types.raw).merge loc)
        lib.composeManyExtensions
      ];
  };
in {
  _file = file;
  key = file;
  options = {
    flake = mkOption {
      type = types.submoduleWith {
        modules = [
          (let
            mappedSpecs = lib.pipe config.overlays [
              (lib.filterAttrs (_: v: v.enable && (v.data != null || v.lua != null)))
              (builtins.mapAttrs (_: v: v // {
                lua = if v.lua == null then [] else [ (util.mkLuaOverlay v.lua) ];
                data = if v.data == null then [] else [ v.data ];
              }))
              (builtins.mapAttrs (_: v: v // {
                data = lib.composeManyExtensions (v.lua ++ v.data);
              }))
            ];
          in {
            _file = file;
            key = file;
            options.overlist = mkOption {
              type = types.listOf types.raw;
              readOnly = true;
              default = lib.pipe mappedSpecs [
                (util.wlib.dag.unwrapSort "overlays")
                (map (v: v.data))
              ];
            };
            config.overlays = builtins.mapAttrs (_: v: v.data) mappedSpecs;
          })
        ];
      };
    };
    overlays = mkOption {
      default = {};
      type = types.lazyAttrsOf (
        util.wlib.types.spec [
          (util.wlib.dag.mkDagEntry {
            dataOptFn = _: {
              type = lib.types.nullOr overlayType;
              description = "overlay";
            };
          })
          {
            options = {
              enable = mkOption {
                default = true;
                type = types.bool;
              };
              lua = mkOption {
                default = null;
                type = types.nullOr (util.wlib.types.spec {
                  options.packageOverrides = mkOption {
                    type = overlayType;
                    description = "lua package overrides";
                  };
                  options.vimPlugins = mkOption {
                    type = types.nullOr overlayType;
                    description = "vimPlugins overrides with awareness of lua package overrides";
                    default = null;
                  };
                  options.versions = mkOption {
                    type = types.listOf types.str;
                    default = [];
                  };
                  options.controlType = mkOption {
                    type = types.enum [ "exclude" "build" ];
                    default = "exclude";
                  };
                });
              };
            };
          }
        ]
      );
    };
  };
}
