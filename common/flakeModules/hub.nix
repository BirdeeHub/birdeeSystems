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
  file = ./hub.nix;
in
{
  _file = file;
  key = file;
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "app-images";
      file = file;
      option = mkOption {
        type = types.lazyAttrsOf types.package;
        default = { };
        description = ''
          perSystem.app-images.<name> = app-images.$${system}.<name>
        '';
      };
    })
  ];

  options = {
    flake = mkOption {
      type = types.submoduleWith {
        modules = [
          {
            _file = file;
            key = file;
            options.util = mkOption {
              type = types.lazyAttrsOf types.raw;
              default = { };
              description = ''
                contains various personal utilities which are not system dependent
              '';
              apply = x: { inherit wlib; } // x;
            };
            options.overlist = mkOption {
              type = lib.types.listOf types.raw;
              readOnly = true;
              default = wlib.dag.sortAndUnwrap { dag = config.overlays; name = "overlays"; mapIfOk = v: v.data; };
            };
            config.overlays = lib.filterAttrs (_: v: v != null) (builtins.mapAttrs (n: v: if v.enable then v.data else null) config.overlays);
          }
        ];
      };
    };
    overlays = mkOption {
      type = types.lazyAttrsOf (wlib.types.spec ({name, config, ...}: {
        options = {
          data = mkOption {
            type = types.raw;
            apply = x: if config.call-data-with-name then x name else x;
          };
          name = mkOption {
            type = types.str;
            default = name;
            readOnly = true;
          };
          before = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          after = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          enable = mkOption {
            default = true;
            type = types.bool;
          };
          call-data-with-name = mkOption {
            default = false;
            type = types.bool;
          };
        };
      }));
      default = { };
    };
  };

}
