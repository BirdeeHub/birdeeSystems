{ inputs, ... }:
{ config, ... }:
{
  _file = ./wrappers.nix;
  key = ./wrappers.nix;
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
