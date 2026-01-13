inputs:
let
  util = import ./util inputs;
  flakeModules = import ./flakeModules { inherit inputs util; };
in
{ lib, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    flakeModules.default
    ./disko
    (lib.modules.importApply ./overlays { inherit inputs util; })
    (lib.modules.importApply ./modules { inherit inputs util; })
    (lib.modules.importApply ./wrappers { inherit inputs util; })
  ];
  flake.flakeModules = flakeModules;
  flake.templates = import ./templates inputs;
  flake.util = util;
}
