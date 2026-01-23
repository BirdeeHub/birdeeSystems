{ inputs, util, ... }:
let
  mkMods =
    homeManager:
    let
      homeOnly = path: (if homeManager then path else throw "no system module with that name");
      systemOnly =
        path: (if homeManager then throw "no home-manager module with that name" else path);
      moduleNamespace = "birdeeMods";
      args = {
        inherit
          inputs
          moduleNamespace
          homeManager
          util
          ;
      };
    in
    {
      LD = import (systemOnly ./LD) args;
      firefox = import (homeOnly ./firefox) args;
      i3 = import ./i3 args;
      i3MonMemory = import ./i3MonMemory args;
      lightdm = import (systemOnly ./lightdm) args;
      zsh = import ./zsh args;
      bash = import ./bash.nix args;
      fish = import ./fish.nix args;
      aliasNetwork = import (systemOnly ./aliasNetwork) args;
      old_modules_compat = import ./old_modules_compat args;
    };
in
{
  flake.modules.nixos = mkMods false;
  flake.modules.homeManager = mkMods true;
}
