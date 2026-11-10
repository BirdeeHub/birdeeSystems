{ inputs, util, ... }@args:
let
  flakeModules =
    let
      inherit (inputs.nixpkgs.lib.modules) importApply;
      initial = {
        app-images = ./app-images.nix;
        overlay = importApply ./overlay.nix args;
        configsPerSystem = importApply ./configsPerSystem.nix args;
        wrappers = importApply ./wrappers.nix args;
        util = ./util.nix;
        inherit (inputs.flake-parts.flakeModules) bundlers modules flakeModules;
      };
    in
    initial
    // {
      default = {
        imports = builtins.attrValues initial;
      };
    };
in
{ config, ... }:
{
  imports = [ flakeModules.default ];
  flake.modules.flake = flakeModules;
  flake.util = util;
  flake.nixosModules = config.flake.modules.nixos;
  flake.flakeModules = config.flake.modules.flake;
}
