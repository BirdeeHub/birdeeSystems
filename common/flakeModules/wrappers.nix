{ inputs, util, ... }:
{ config, ... }:
let
  installMods = builtins.mapAttrs (_: v: v.install) config.flake.wrappers;
  file = ./wrappers.nix;
in
{
  _file = file;
  key = file;
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.wrappers.flakeModules.wrappers
  ];
  config.flake.modules.homeManager = installMods;
  config.flake.modules.nixos = installMods;
  config.flake.modules.darwin = installMods;
  config.flake.modules.generic = installMods;
}
