{ inputs, util }@args: let
  inherit (inputs.nixpkgs.lib.modules) importApply;
  flakeModules = {
    app-images = ./app-images.nix;
    overlay = importApply ./overlay.nix args;
    configsPerSystem = importApply ./configsPerSystem.nix args;
    wrappers = importApply ./wrappers.nix args;
    util = importApply ./util.nix args;
  };
in flakeModules // {
  default = {
    imports = builtins.attrValues flakeModules;
  };
}
