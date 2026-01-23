{ inputs, util, ... }:
let
  mkMods =
    homeManager:
    let
      args = {
        moduleNamespace = "birdeeMods";
        inherit
          inputs
          homeManager
          util
          ;
      };
    in
    {
      i3 = import ./i3 args;
      i3MonMemory = import ./i3MonMemory args;
      zsh = import ./zsh args;
      bash = import ./bash.nix args;
      fish = import ./fish.nix args;
    } // (if homeManager then {
      firefox = import ./firefox args;
    } else {
      LD = import ./LD args;
      lightdm = import ./lightdm args;
      aliasNetwork = import ./aliasNetwork args;
    });
in
{
  flake.modules.nixos = mkMods false;
  flake.modules.homeManager = mkMods true;
}
