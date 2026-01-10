inputs: let
  flakeModules = import ./flakeModules inputs;
  util = import ./util inputs;
  inherit (inputs.nixpkgs.lib.modules) importApply;
in {
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
    flakeModules.wrapper
    flakeModules.overlay
    flakeModules.misc
    flakeModules.configsPerSystem
    ./disko
    (importApply ./overlays { inherit inputs util; })
  ];
  flake.wrapperModules = import ./wrappers { inherit inputs util; };
  flake.flakeModules = {
    default = {
      imports = [ flakeModules.hub flakeModules.configsPerSystem flakeModules.wrapper ];
    };
  } // flakeModules;
  flake.nixosModules = import ./modules { inherit inputs util; homeManager = false; };
  flake.homeModules = import ./modules { inherit inputs util; homeManager = true; };
  flake.templates = import ./templates inputs;
  flake.util = util;
}
