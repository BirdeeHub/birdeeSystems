{ inputs, ... }: let
  util = import ./util inputs;
in {
  inherit util;
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
    inherit (inputs.nixpkgs) lib;
    nixosMods = (import ./modules { inherit inputs util; homeManager = false; });
    homeMods = (import ./modules { inherit inputs util; homeManager = true; });
    overs = (import ./overlays { inherit inputs util; });
    usrdta = pkgs: import ./userdata { inherit inputs util; } pkgs;
    wrapperModules = import ./wrappers { inherit inputs util; };
    flakeMods = import ./flakeModules { inherit inputs util; };
  in {
    home-modules = lib.optionalAttrs HM homeMods;
    system-modules = lib.optionalAttrs nixos nixosMods;
    overlaySet = lib.optionalAttrs overlays overs.overlaySet;
    overlayList = lib.optionals overlays overs.overlayList;
    diskoCFG = lib.optionalAttrs disko (import ./disko);
    flakeModules = lib.optionalAttrs flakeModules flakeMods;
    templates = lib.optionalAttrs templates (import ./templates inputs);
    userdata = if userdata then usrdta else (_:{});
    wrapperModules = if wrappers then wrapperModules else {};
  };
}
