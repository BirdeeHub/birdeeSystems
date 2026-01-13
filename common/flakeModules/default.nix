{ inputs, util }@args: let
  inherit (inputs.nixpkgs.lib.modules) importApply;
  flakeModules = {
    app-images = importApply ./app-images.nix args;
    overlay = importApply ./overlay.nix args;
    configsPerSystem = importApply ./configsPerSystem.nix args;
    wrapper = importApply ./wrapper.nix args;
    util = importApply ./util.nix args;
  };
in flakeModules // {
  default = {
    imports = builtins.attrValues flakeModules;
  };
}
