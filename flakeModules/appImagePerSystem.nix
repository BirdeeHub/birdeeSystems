{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
mkTransposedPerSystemModule {
  name = "app-images";
  option = mkOption {
    type = types.lazyAttrsOf types.package;
    default = { };
    description = ''
    '';
  };
  file = ./appImagePerSystem.nix;
}
