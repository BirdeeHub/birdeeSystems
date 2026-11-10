{ inputs, moduleNamespace, ... }:
let
  name = "virtualisation";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
      inVM = lib.mkEnableOption "only enable things that you would use in a VM";
    };
    config = lib.mkIf cfg.enable {
      virtualisation.libvirtd.enable = lib.mkIf (!cfg.inVM) true;
      virtualisation.docker.enable = true;
      # hardware.nvidia-container-toolkit.enable = pkgs.lib.mkIf (config.virtualisation.docker.enable == true) true;
    };
  };
}
