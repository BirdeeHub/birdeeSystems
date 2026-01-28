inputs:
let
  util = import ./util inputs // { wlib = inputs.wrappers.lib; };
  flakeModules = import ./flakeModules { inherit inputs util; };
in
{ lib, config, ... }:
{
  flake.modules.flake = flakeModules;
  flake.templates = import ./templates inputs;
  flake.util = util;
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    inputs.flake-parts.flakeModules.modules
    inputs.flake-parts.flakeModules.bundlers
    # inputs.flake-parts.flakeModules.easyOverlay
    # inputs.flake-parts.flakeModules.partitions
    flakeModules.default
    ./disko
    (lib.modules.importApply ./overlays { inherit inputs util; })
    (lib.modules.importApply ./modules { inherit inputs util; })
    (lib.modules.importApply ./wrappers { inherit inputs util; })
  ];
  flake.nixosModules = config.flake.modules.nixos;
  flake.flakeModules = config.flake.modules.flake;
}
