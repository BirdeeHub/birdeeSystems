{ config, pkgs, self, inputs, lib, ... }: {
  imports = [
  ];
  options = {
    birdeeMods.lightdm = with lib.types; {
      enable = lib.mkEnableOption "birdee's lightdm module";
      sessionCommands = lib.mkOption {
        default = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
            Xft.dpi: 100
          ''}
        '';
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
    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.displayManager.session = [
      {
        manage = "window";
        name = "fake";
        start = "";
      }
    ];

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
      sessionCommands = lib.mkIf (cfg.sessionCommands != null) cfg.sessionCommands;
    };
    # services.displayManager.defaultSession = "none+i3";
    services.displayManager.defaultSession = "none+fake";

    environment.systemPackages = [
    ];

    services.dbus.packages = [
    ];

    qt.platformTheme = "gtk2";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      # libsForQt5.xdg-desktop-portal-kde
      # xdg-desktop-portal-gnome
      xdg-dbus-proxy
    ];
    xdg.portal.config.common.default = "*";

    programs.xfconf.enable = true;

    services.dbus.enable = true;
    services.xserver.updateDbusEnvironment = true;
    programs.gdk-pixbuf.modulePackages = with pkgs; [ gdk-pixbuf librsvg  ];

    programs.dconf.enable = true;
    services.upower.enable = true;
    services.udisks2.enable = true;
    services.gnome.glib-networking.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.system-config-printer.enable = true;

    environment.pathsToLink = [
      "/share/xfce4"
      "/lib/xfce4"
      "/share/gtksourceview-3.0"
      "/share/gtksourceview-4.0"
    ];

  });
}
