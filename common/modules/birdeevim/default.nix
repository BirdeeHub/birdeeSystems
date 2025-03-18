{ moduleNamespace, inputs, homeManager, birdeeutils, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.birdeevim;
  inherit (config.birdeevim) utils;
in {
  _file = ./default.nix;
  imports = if homeManager then [inputs.birdeevim.homeModule] else [inputs.birdeevim.nixosModule];
  options = {
    ${moduleNamespace}.birdeevim = with lib.types; {
      enable = lib.mkEnableOption "birdee's nvim config";
      packageNames = lib.mkOption {
        default = [];
        type = listOf str;
      };
    };
  };
  config = {
    birdeevim = let
      replacements = builtins.mapAttrs (n: _: { pkgs, ... }: {
        settings = {
          moduleNamespace = [ moduleNamespace n ];
        };
        extra = {
          nixdExtras = {
            flake-path = ''${inputs.self.outPath}'';
          };
        };
      }) inputs.birdeevim.packages.${pkgs.system}.default.packageDefinitions;
    in {
      inherit (cfg) enable packageNames;
      packageDefinitions.replace = replacements;
      # packageDefinitions.merge = merges;
    };
  };
}
