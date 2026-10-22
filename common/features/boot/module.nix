{ inputs, moduleNamespace, ... }:
let
  name = "boot";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
      type = lib.mkOption {
        type = lib.types.enum [ "systemd" "grub" ];
        default = "systemd";
      };
    };
    config = lib.mkIf cfg.enable {
      # Bootloader.
      boot.loader.timeout = 3;
      boot.loader.grub.enable = lib.mkIf (cfg.type == "grub") true;
      # boot.loader.grub.efiSupport = true;
      # boot.loader.grub.efiInstallAsRemovable = true;
      boot.loader.systemd-boot.editor = lib.mkIf (cfg.type == "systemd") false;
      boot.loader.systemd-boot.configurationLimit = lib.mkIf (cfg.type == "systemd") 50;
      boot.loader.systemd-boot.enable = lib.mkIf (cfg.type == "systemd") true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
  };
}
