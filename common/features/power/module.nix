{moduleNamespace, inputs, ...}: {
  flake.modules.nixos.power = {pkgs, config, lib, ...}:
  let
    cfg = config.${moduleNamespace}.power;
  in
  {
    _file = ./module.nix;
    options.${moduleNamespace}.power = {
      enable = lib.mkEnableOption "power management dependencies";
      fixAMDpowerSave = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Prevent AMD pci devices from turning all the way off during power saver mode.
          Makes it so kernel doesn't stop sending monitor hotplug uevents.
        '';
      };
    };
    config = lib.mkIf cfg.enable {

      services.udev.extraRules = lib.mkIf cfg.fixAMDpowerSave ''
        SUBSYSTEM=="pci", ATTRS{vendor}=="0x1002", ATTR{power/control}="on"
      '';
      services.dbus.enable = true;
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      services.logind.enable = true;
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
        HandlePowerKey =  "poweroff";
        HandleRebootKey = "reboot";
        HandleSuspendKey = "suspend";
        HandleHibernateKey = "hibernate";
        HandlePowerKeyLongPress = "poweroff";
        HandleRebootKeyLongPress = "poweroff";
        HandleSuspendKeyLongPress = "hibernate";
        HandleHibernateKeyLongPress = "ignore";
        HandleSecureAttentionKey = "secure-attention-key";
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "1h";
      };
      systemd.sleep.settings.Sleep.HibernateDelaySec = "10min";
    };
  };
}
