{ inputs, flake-path, ... }: let
  birdeeutils = import ./util inputs;
  birdeeVim = import ./birdeevim { inherit inputs flake-path birdeeutils; };
in {
  inherit birdeeVim birdeeutils;
  hub = { HM ? true
  , nixos ? true
  , overlays ? true
  , packages ? true
  , disko ? true
  , flakeMods ? true
  , templates ? true
  , userdata ? true
  , ...
  }: let
    inherit (inputs.nixpkgs) lib;
    nixosMods = (import ./modules { inherit inputs birdeeutils; homeManager = false; }) // { birdeeVim = birdeeVim.nixosModules.default; };
    homeMods = (import ./modules { inherit inputs birdeeutils; homeManager = true; }) // { birdeeVim = birdeeVim.homeModule; };
    overs = (import ./overlays { inherit inputs birdeeutils; }) // { birdeeVim = birdeeVim.overlays.default; };
    mypkgs = system: (import ./pkgs { inherit inputs system birdeeutils; }) // birdeeVim.packages.${system};
    usrdta = pkgs: import ./userdata { inherit inputs birdeeutils; } pkgs;
    FM = import ./flakeModules { inherit inputs birdeeutils; };
  in {
    home-modules = lib.optionalAttrs HM homeMods;
    system-modules = lib.optionalAttrs nixos nixosMods;
    overlaySet = lib.optionalAttrs overlays overs;
    packages = if packages then mypkgs else (_:{});
    diskoCFG = lib.optionalAttrs disko (import ./disko);
    flakeModules = lib.optionalAttrs flakeMods FM;
    templates = lib.optionalAttrs templates (import ./templates inputs);
    userdata = if userdata then usrdta else (_:{});
  };
}
