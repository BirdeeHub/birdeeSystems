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
            enabled-overlays = lib.filterAttrs (_: v: v.enable) config.overlays;
            sorted-overlays = util.wlib.dag.unwrapSort "overlays" enabled-overlays;
            lua-overlay = final: prev: let
              luaInterpreters = lib.pipe sorted-overlays [
                (builtins.concatMap (v: if v.lua or null != null then [ v.lua ] else []))
                (util.wlib.dag.unwrapSort "lua overlays")
                (map (
                  v: v // {
                    versions = if v.controlType == "build" then
                      lib.intersectLists v.versions (builtins.attrNames prev.luaInterpreters)
                    else
                      lib.pipe prev.luaInterpreters [
                        builtins.attrNames
                        (builtins.filter (x: !builtins.elem x v.versions))
                      ];
                  }
                ))
                (map (
                  value: lib.pipe value.versions [
                    (map (v: lib.nameValuePair v value.data))
                    builtins.listToAttrs
                  ]
                ))
                (builtins.zipAttrsWith (_: vs: vs))
                (builtins.mapAttrs (
                  n: list: (lib.attrByPath [ n "override" ] null prev.luaInterpreters) (old: {
                    packageOverrides = lib.composeManyExtensions ((lib.optional (old ? packageOverrides) old.packageOverrides) ++ list);
                  })
                ))
              ];
            in {
              # https://github.com/NixOS/nixpkgs/blob/dd950ec2fda73b76273d3812a1a5cf35c77b4b69/pkgs/top-level/all-packages.nix#L4866-L4907
              luaInterpreters = prev.luaInterpreters // luaInterpreters;
              inherit (final.luaInterpreters)
              lua5_1
              lua5_2
              lua5_2_compat
              lua5_3
              lua5_3_compat
              lua5_4
              lua5_4_compat
              lua5_5
              lua5_5_compat
              luajit_2_1
              luajit_2_0
              luajit_openresty;

              lua5 = final.lua5_2_compat;
              lua = final.lua5;
              lua51Packages = lib.recurseIntoAttrs final.lua5_1.pkgs;
              lua52Packages = lib.recurseIntoAttrs final.lua5_2.pkgs;
              lua53Packages = lib.recurseIntoAttrs final.lua5_3.pkgs;
              lua54Packages = lib.recurseIntoAttrs final.lua5_4.pkgs;
              lua55Packages = lib.recurseIntoAttrs final.lua5_5.pkgs;
              luajitPackages = lib.recurseIntoAttrs final.luajit.pkgs;
              luaPackages = final.lua52Packages;
              luajit = final.luajit_2_1;
              emiluaPlugins = lib.recurseIntoAttrs (final.callPackage ./emilua-plugins.nix {} (final.callPackage ../development/interpreters/emilua {}));
              inherit (final.emiluaPlugins) emilua;
              luarocks = final.luaPackages.luarocks;
              luarocks-nix = final.luaPackages.luarocks-nix;
              toluapp = final.callPackage ../development/tools/toluapp { lua = final.lua5_1; };
            };
          in {
            _file = file;
            key = file;
            options.overlist = mkOption {
              type = types.listOf types.raw;
              readOnly = true;
              default = [ lua-overlay ] ++ builtins.concatMap (v: if v.data or null != null then [ v.data ] else []) sorted-overlays;
            };
            config.overlays = builtins.mapAttrs (n: v: v.data) (lib.filterAttrs (n: v: v.data or null != null) enabled-overlays) // {
              combined-lua-overlays = lua-overlay;
            };
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
            };
          })
          ({ name, ... }: {
            options = {
              enable = mkOption {
                default = true;
                type = types.bool;
              };
              lua = mkOption {
                default = null;
                type = types.nullOr (
                  util.wlib.types.spec [
                    (util.wlib.dag.mkDagEntry {
                      isDal = true;
                      dataOptFn = _: { type = overlayType; description = "lua package overlay"; };
                    })
                    {
                      config._module.args.name = lib.mkForce name;
                      config.name = name;
                      options.versions = mkOption {
                        type = types.listOf types.str;
                        default = [];
                      };
                      options.controlType = mkOption {
                        type = types.enum [ "exclude" "build" ];
                        default = "exclude";
                      };
                    }
                  ]
                );
              };
            };
          })
        ]
      );
    };
  };
}
