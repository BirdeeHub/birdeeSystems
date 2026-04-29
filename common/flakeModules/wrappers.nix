{ inputs, util, ... }:
{ config, ... }:
let
  file = ./wrappers.nix;
in
{
  _file = file;
  key = file;
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.wrappers.flakeModules.wrappers
  ];
  config.flake.modules = let
    installMods = builtins.mapAttrs (_: v: v.install) config.flake.wrappers;
  in {
    homeManager = installMods;
    nixos = installMods;
    darwin = installMods;
    generic = installMods;
  };
}
