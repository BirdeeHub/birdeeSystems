{ inputs, ... }: let
  birdeeutils = import ./util inputs;
in {
  inherit birdeeutils;
  hub = { HM ? true
  , nixos ? true
  , overlays ? true
  , disko ? true
  , flakeModules ? true
  , templates ? true
  , userdata ? true
  , wrappers ? true
  , ...
  }: let
    inherit (inputs.nixpkgsNV) lib;
    nixosMods = (import ./modules { inherit inputs birdeeutils; homeManager = false; });
    homeMods = (import ./modules { inherit inputs birdeeutils; homeManager = true; });
    overs = (import ./overlays { inherit inputs birdeeutils; });
    usrdta = pkgs: import ./userdata { inherit inputs birdeeutils; } pkgs;
    wrapperModules = import ./wrappers { inherit inputs birdeeutils; };
    flakeMods = import ./flakeModules { inherit inputs birdeeutils; };
  in {
    home-modules = lib.optionalAttrs HM homeMods;
    system-modules = lib.optionalAttrs nixos nixosMods;
    overlaySet = lib.optionalAttrs overlays overs.overlaySet;
    overlayList = lib.optionals overlays overs.overlayList;
    diskoCFG = lib.optionalAttrs disko (import ./disko);
    flakeModules = lib.optionalAttrs flakeModules flakeMods;
    templates = lib.optionalAttrs templates (import ./templates inputs);
    userdata = if userdata then usrdta else (_:{});
    wrappers = if wrappers then wrapperModules else {};
  };
}
