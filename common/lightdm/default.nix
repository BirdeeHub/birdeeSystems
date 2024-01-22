{ config, pkgs, self, inputs, lib, ... }: {
  imports = [
  ];
  options = {
    birdeeMods.lightdm = with lib.types; {
      enable = lib.mkEnableOption "birdee's lightdm module";
      sessionCommands = lib.mkOption {
        default = null;
        type = nullOr str;
      };
      dpi = lib.mkOption {
        default = null;
        type = nullOr int;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.lightdm.enable (let
    cfg = config.birdeeMods.lightdm;
  in {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.xserver.dpi = lib.mkIf (cfg.dpi != null) cfg.dpi;

    services.xserver.displayManager = {
      lightdm = {
        enable = true;
        greeter = {
          enable = true;
        };
        extraConfig = ''
        '';
      };
      defaultSession = "none+i3";
      sessionCommands = lib.mkIf (cfg.sessionCommands != null) cfg.sessionCommands;
    };
  });
}
