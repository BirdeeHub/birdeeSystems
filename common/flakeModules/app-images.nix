{ inputs, util }:
let
  wlib = inputs.wrappers.lib;
in
{
  lib,
  flake-parts-lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) types mkOption;
  file = ./app-images.nix;
in
flake-parts-lib.mkTransposedPerSystemModule {
  name = "app-images";
  file = file;
  option = mkOption {
    type = types.lazyAttrsOf types.package;
    default = { };
    description = ''
      perSystem.app-images.<name> = app-images.$${system}.<name>
    '';
  };
}
