inputs:
let
  util = import ./util inputs;
  flakeModules =
    let
      initial = import ./flakeModules { inherit inputs util; };
    in
    initial
    // {
      default = {
        imports = builtins.attrValues initial;
      };
    };
in
{ lib, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    flakeModules.wrapper
    flakeModules.overlay
    flakeModules.misc
    flakeModules.configsPerSystem
    ./disko
    (lib.modules.importApply ./overlays { inherit inputs util; })
    (lib.modules.importApply ./modules { inherit inputs util; })
    (lib.modules.importApply ./wrappers { inherit inputs util; })
  ];
  flake.flakeModules = flakeModules;
  flake.templates = import ./templates inputs;
  flake.util = util;
}
