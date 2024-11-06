{ moduleNamespace, homeManager, inputs, ... }:
{config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.nu;
in {
  _file = ./nu.nix;
  options = {
    ${moduleNamespace}.nu.enable = lib.mkEnableOption "birdeeNu";
  };
  # TODO: set it up to try it out
  config = lib.mkIf cfg.enable (let
  in if homeManager then {
  } else {
  });
}
