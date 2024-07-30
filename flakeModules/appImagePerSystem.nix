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
      perSystem.app-images.<name> = app-images.$${system}.<name>
    '';
  };
  file = ./appImagePerSystem.nix;
}
