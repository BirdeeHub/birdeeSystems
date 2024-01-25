{ config, pkgs, self, inputs, lib, ... }: {


# WORK IN PROGRESS
# The goal is to move the entire thing into home manager if I can.

  imports = [
  ];
  options = {
    birdeeMods.i3 = with lib.types; {
      enable = lib.mkEnableOption "birdee's i3 configuration";
      dmenu = {
          terminalStr = lib.mkOption {
            default = ''alacritty'';
            type = str;
          };
      };
    };
  };
  config = lib.mkIf config.birdeeMods.i3.enable (let
    cfg = config.birdeeMods.i3;
  in {
    xsession.initExtra = ''
      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all || true
    '';
    xsession.windowManager.i3 = {
      enable = true;
      extraConfig = (let
        monMover = (pkgs.writeShellScript "monWkspcCycle.sh" ''
          jq() {
            ${pkgs.jq}/bin/jq "$@"
          }
          xrandr() {
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
          }
          ${builtins.readFile ../monWkspcCycle.sh}
        '');
        fehBG = (pkgs.writeShellScript "fehBG" ''
          exec ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${../misc/rooftophang.png} "$@"
        '');
        xtraTermCMD = ''alacritty -e tx'';
        termCMD = ''alacritty'';
      in ''
        set $monMover ${monMover}
        set $fehBG ${fehBG}
        set $termCMD ${termCMD}
        set $xtraTermCMD ${xtraTermCMD}
      '');
    };

    home.packages = (let
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
      i3lock = (pkgs.writeShellScriptBin "i3lock" ''
        exec ${pkgs.i3lock}/bin/i3lock -t -i ${../misc/DogAteHomework.png} "$@"
      '');
    in
    with pkgs; with pkgs.xfce; [
      i3lock #default i3 screen locker
      i3status #default i3 status bar
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
      # xorg.libXinerama
      # dex
      # hicolor-icon-theme
      # tango-icon-theme
      # xfce4-icon-theme
      # gnome.gnome-themes-extra
      # gnome.adwaita-icon-theme
    ]);

  });
}
