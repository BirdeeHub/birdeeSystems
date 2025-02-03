{ moduleNamespace, homeManager, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.ranger;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.ranger = with lib.types; {
      enable = lib.mkEnableOption "aliases for new options for things on old channels";
    };
  };
  config = lib.mkIf cfg.enable (let
  in if homeManager then {
  } else {
  });
}
