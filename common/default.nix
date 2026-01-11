inputs: let
  flakeModules = import ./flakeModules inputs;
  util = import ./util inputs;
in { lib, ... }: {
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    flakeModules.wrapper
    flakeModules.overlay
    flakeModules.misc
    flakeModules.configsPerSystem
    ./disko
    (lib.modules.importApply ./overlays { inherit inputs util; })
    (lib.modules.importApply ./modules { inherit inputs util; })
  ];
  flake.wrapperModules = import ./wrappers { inherit inputs util; };
  flake.flakeModules = {
    default = {
      imports = [ flakeModules.hub flakeModules.configsPerSystem flakeModules.wrapper ];
    };
  } // flakeModules;
  flake.templates = import ./templates inputs;
  flake.util = util;
}
