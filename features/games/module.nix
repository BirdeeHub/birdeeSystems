{ inputs, util, moduleNamespace, ... }:
let
  name = "games";
  module = { pkgs, config, lib, _class, ... }: let
    cfg = config.${moduleNamespace}.${name};
    packages = let
      withDGPU = fpkg: util.wlib.wrapPackage [
        { inherit pkgs; }
        ({pkgs, ... }:{ package = fpkg pkgs; env.DRI_PRIME = toString 1; })
      ];
    in [
      (withDGPU (p: p.steam))
      (withDGPU (p: p.heroic))
      # lutris
    ];
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = {
      nixos.environment = lib.mkIf cfg.enable { systemPackages = packages; };
      homeManager.home = lib.mkIf cfg.enable { inherit packages; };
      hjem = lib.mkIf cfg.enable { inherit packages; };
    }.${_class};
  };
in
{
  flake.modules.homeManager.${name} = module;
  flake.modules.hjem.${name} = module;
  flake.modules.nixos.${name} = module;
}
