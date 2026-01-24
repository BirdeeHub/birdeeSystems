{ inputs, util }:
{ lib, ... }:
let
  inherit (lib) types mkOption;
  file = ./util.nix;
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
            options.util = mkOption {
              type = types.lazyAttrsOf types.raw;
              default = { };
              description = ''
                contains various personal utilities which are not system dependent
              '';
              apply = x: { wlib = inputs.wrappers.lib; } // x;
            };
          }
        ];
      };
    };
  };
}
