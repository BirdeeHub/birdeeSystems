{ config, pkgs, self, inputs, lib, ... }: {
  imports = [
    (import ../xrandrMemoryi3 { home-manager = false;})
  ];
  options = {
    birdeeMods.i3 = with lib.types; {
      enable = lib.mkEnableOption "birdee's i3 configuration";
      bootUpMonScript = lib.mkOption {
        default = null;
        type = nullOr path;
      };
      i3blocks = {
        enable = lib.mkEnableOption "swap i3status for i3blocks";
      };
      dmenu = {
          terminalStr = lib.mkOption {
            default = ''alacritty'';
            type = str;
          };
      };
      extraSessionCommands = lib.mkOption {
        default = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
            Xft.dpi: 100
          ''}
        '';
        type = str;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.i3.enable (let
    cfg = config.birdeeMods.i3;
  in {
    services.xserver.desktopManager.xterm.enable = false;

      # Enable the i3 Desktop Environment.
    services.xserver.windowManager.i3 = {
      enable = true;
      updateSessionEnvironment = true;
      configFile = let
        monMover = (pkgs.writeScript "monWkspcCycle.sh" (''
          #!/usr/bin/env bash
          jq() {
            ${pkgs.jq}/bin/jq "$@"
          }
          xrandr() {
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
          }
        '' + (builtins.readFile ../monWkspcCycle.sh) + ''
        ''));
        fehBG = (pkgs.writeScript "fehBG" ''
          #!/bin/sh
          exec ${pkgs.feh}/bin/feh --bg-scale ${../misc/rooftophang.png} "$@"
        '');
        bootUpMonScript = pkgs.writeScript "bootUpMon.sh" (if cfg.bootUpMonScript != null then ''
          #!/usr/bin/env bash
          xrandr() {
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
          }
        '' + (builtins.readFile cfg.bootUpMonScript)
        else ''
          #!/usr/bin/env bash
          ${pkgs.xorg.xrandr}/bin/xrandr --auto
        '');
      in "${ pkgs.writeText "config" (''
          set $monMover ${monMover}
          set $fehBG ${fehBG}
          set $xrandr ${pkgs.xorg.xrandr}/bin/xrandr
          set $bootUpMonScript ${bootUpMonScript}
        '' + builtins.readFile ../config + ''
        '') }";
      # extraSessionCommands = cfg.extraSessionCommands;
    };

    environment.systemPackages = (let
      dmenu = pkgs.writeShellScriptBin "dmenu_run" (/* bash */''
        dmenu() {
          ${pkgs.dmenu}/bin/dmenu "$@"
        }
        dmenu_path() {
          ${pkgs.dmenu}/bin/dmenu_path "$@"
        }
        TERMINAL=${cfg.dmenu.terminalStr}
      '' + (builtins.readFile ../misc/dmenu_recency.sh));
      dmenuclr_recent = ''${pkgs.writeShellScriptBin "dmenuclr_recent" (/*bash*/''
        cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
        cache="$cachedir/dmenu_recent"
        rm $cache
      '')}'';
      i3status = (pkgs.writeShellScriptBin "i3status" ''
        exec ${pkgs.i3status}/bin/i3status --config ${builtins.toFile "i3bar" (builtins.readFile ../i3bar)} "$@"
      '');
      i3lock = (pkgs.writeScriptBin "i3lock" ''
        #!/bin/sh
        exec ${pkgs.i3lock}/bin/i3lock -t -i ${../misc/DogAteHomework.png} "$@"
      '');
    in
    with pkgs; with pkgs.xfce; [
      i3lock #default i3 screen locker
      xss-lock
      libnotify
      dmenu #application launcher most people use
      dmenuclr_recent
      pa_applet
      pavucontrol
      networkmanagerapplet
      xfce4-volumed-pulse
      lm_sensors
      glib # for gsettings
      gtk3.out # gtk-update-icon-cache
      desktop-file-utils
      shared-mime-info # for update-mime-database
      polkit_gnome
      xdg-utils
      xdg-user-dirs
      garcon
      libxfce4ui
      xfce4-power-manager
      xfce4-notifyd
      xfce4-screenshooter
      xfce4-taskmanager
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtgraphicaleffects
      # dex
      # hicolor-icon-theme
      # tango-icon-theme
      # xfce4-icon-theme
      # gnome.gnome-themes-extra
      # gnome.adwaita-icon-theme
    ] ++ (if cfg.i3blocks.enable == true then [ i3blocks ] else [ i3status ]));
    qt.platformTheme = "gtk";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal pkgs.xdg-desktop-portal-gtk ];
    xdg.portal.config.common.default = "*";

    programs.xfconf.enable = true;

    services.dbus.enable = true;
    services.xserver.updateDbusEnvironment = true;
    services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg pkgs.gdk-pixbuf ];

    programs.dconf.enable = true;
    services.upower.enable = true;
    services.udisks2.enable = true;
    services.gnome.glib-networking.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.system-config-printer.enable = true;

    programs.bash.vteIntegration = true;
    programs.zsh.vteIntegration = true;

    environment.pathsToLink = [
      "/share/xfce4"
      "/lib/xfce4"
      "/share/gtksourceview-3.0"
      "/share/gtksourceview-4.0"
    ] ++ (if cfg.i3blocks.enable == true then [ "/libexec" ] else []);
  });
}
