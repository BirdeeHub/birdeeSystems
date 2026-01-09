{
  lib,
  flake-parts-lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) types mkOption genAttrs;
  file = ./hub.nix;
  hubutils = config.flake.util;
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
              type = types.attrsOf types.raw;
              default = { };
              description = ''
                contains various personal utilities which are not system dependent
              '';
              apply = x: x // { wlib = inputs.wrappers.lib; };
            };
          }
        ];
      };
    };
    perSystem = flake-parts-lib.mkPerSystemOption (
      { system, pkgs, ... }:
      {
        _file = file;
        key = file;
      }
    );
  };

}
