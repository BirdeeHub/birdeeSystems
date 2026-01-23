{ inputs, util }:
{ config, ... }:
let
  installMods = builtins.mapAttrs (name: value: {
    inherit name value;
    __functor = util.mkInstallModule;
  }) config.flake.wrapperModules;
  file = ./wrapperMods.nix;
in
{
  _file = file;
  key = file;
  imports = [ inputs.flake-parts.flakeModules.modules ];
  config.flake.modules.homeManager = builtins.mapAttrs (
    _: v:
    v
    // {
      loc = [
        "home"
        "packages"
      ];
    }
  ) installMods;
  config.flake.modules.nixos = installMods;
  config.flake.modules.darwin = installMods;
  config.flake.modules.generic = config.flake.wrapperModules // {
    default = {
      imports = builtins.attrValues installMods;
    };
  };
}
