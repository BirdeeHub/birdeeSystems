{ inputs, moduleNamespace, ... }:
let
  name = "antivirus";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
      services.clamav.daemon.enable = true;
      services.clamav.updater.enable = true;
      services.clamav.updater.interval = "weekly";
    };
  };
}
