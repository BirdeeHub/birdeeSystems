{ moduleNamespace, inputs, ... }:
{
  flake.modules.nixos.lightdm =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.lightdm;
    in
    {
      _file = ./module.nix;
      options = {
        ${moduleNamespace}.lightdm = with lib.types; {
          enable = lib.mkEnableOption "birdee's lightdm module";
          sessionCommands = lib.mkOption {
            default = ''
              ${pkgs.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
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
      config = lib.mkIf cfg.enable {
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
            greeters.gtk.enable = true;
            extraConfig = "";
          };
          sessionCommands = lib.mkIf (cfg.sessionCommands != null) cfg.sessionCommands;
        };
        # services.displayManager.defaultSession = lib.mkDefault "none+fake";
        # services.displayManager.defaultSession = lib.mkOverride 1000 "none+fake";
        services.displayManager.defaultSession = lib.mkOverride 1002 "none+fake";
        services.xserver.updateDbusEnvironment = true;

        xdg.portal.enable = true;
        xdg.portal.extraPortals = with pkgs; [
          xdg-desktop-portal
          xdg-desktop-portal-gtk
          xdg-dbus-proxy
        ];
        xdg.portal.config.common.default = "*";

        security.polkit.enable = true;
        programs.gdk-pixbuf.modulePackages = with pkgs; [
          gdk-pixbuf
          librsvg
        ];

        services.udisks2.enable = true;
        services.gnome.glib-networking.enable = true;
        services.gvfs.enable = true;

        environment.pathsToLink = [
          "/share/gtksourceview-3.0"
          "/share/gtksourceview-4.0"
        ];

      };
    };
}
