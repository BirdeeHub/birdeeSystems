{ inputs, ... }: let
  birdeeutils = import ./util inputs;
in {
  inherit birdeeutils;
  hub = { HM ? true
  , nixos ? true
  , overlays ? true
  , packages ? true
  , disko ? true
  , flakeMods ? true
  , templates ? true
  , userdata ? true
  , wrappers ? true
  , ...
  }: let
    inherit (inputs.nixpkgsNV) lib;
    nixosMods = (import ./modules { inherit inputs birdeeutils; homeManager = false; });
    homeMods = (import ./modules { inherit inputs birdeeutils; homeManager = true; });
    overs = (import ./overlays { inherit inputs birdeeutils; });
    mypkgs = system: (import ./pkgs { inherit inputs system birdeeutils; });
    usrdta = pkgs: import ./userdata { inherit inputs birdeeutils; } pkgs;
    FM = import ./flakeModules { inherit inputs birdeeutils; };
    wrapperModules = import ./wrappers { inherit inputs birdeeutils; };
  in {
    home-modules = lib.optionalAttrs HM homeMods;
    system-modules = lib.optionalAttrs nixos nixosMods;
    packages = if packages then mypkgs else (_:{});
    overlaySet = lib.optionalAttrs overlays overs.overlaySet;
    overlayList = lib.optionals overlays overs.overlayList;
    diskoCFG = lib.optionalAttrs disko (import ./disko);
    flakeModules = lib.optionalAttrs flakeMods FM;
    templates = lib.optionalAttrs templates (import ./templates inputs);
    userdata = if userdata then usrdta else (_:{});
    wrappers = if wrappers then wrapperModules else {};
  };
}
