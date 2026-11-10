{ inputs, moduleNamespace, ... }:
let
  name = "input";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;
      services.libinput.touchpad.disableWhileTyping = true;
      # services.xserver.synaptics.enable = true;
      # services.xserver.synaptics.palmDetect = true;
    };
  };
}
