{ inputs, util, moduleNamespace, ... }:
let
  name = "games";
in
{
  flake.modules.homeManager.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
      home.packages = let
        withDGPU = fpkg: util.wlib.wrapPackage [
          { inherit pkgs; }
          ({pkgs, ... }:{ package = fpkg pkgs; env.DRI_PRIME = toString 1; })
        ];
      in [
        (withDGPU (p: p.steam))
        (withDGPU (p: p.heroic))
        # lutris
      ];
    };
  };
}
