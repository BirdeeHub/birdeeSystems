{ config, pkgs, self, inputs, lib, ... }: {


# WORK IN PROGRESS
# I need to test stuff out like keyrings with this setup because
# I am usure if my dbus-update-activation-environment
# work around worked.
# For some reason, it removes my border indicator for focused windows
# on firefox when loaded via home manager and it drives me nuts.

# will swap to this one when those are figured out.

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
      terminalStr = lib.mkOption {
        default = ''alacritty'';
        type = str;
      };
      extraSessionCommands = lib.mkOption {
        default = null;
        type = nullOr str;
      };
      tmuxDefault = lib.mkEnableOption "swap tmux default alacritty to mod+enter from mod+shift+enter";
      defaultLockerEnabled = lib.mkOption { 
        default = true;
        type = bool;
        description = "default locker = i3lock + xss-lock";
      };
      prependedConfig = lib.mkOption {
        default = '''';
        type = str;
      };
      appendedConfig = lib.mkOption {
        default = '''';
        type = str;
      };
      background = lib.mkOption {
        default = ../misc/rooftophang.png;
        type = nullOr path;
      };
      lockerBackground = lib.mkOption {
        default = ../misc/DogAteHomework.png;
        type = nullOr path;
      };
    };
  };
  config = lib.mkIf config.birdeeMods.i3.enable (let
    cfg = config.birdeeMods.i3;
  in {
    xsession.enable = true;
    xsession.scriptPath = ".xsession";
    xsession.initExtra = ''
      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all || true
    '' + (if cfg.extraSessionCommands == null then "" else cfg.extraSessionCommands);
    xsession.windowManager.i3 = {
      enable = true;
      config = null;
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
        fehBG = (pkgs.writeShellScript "fehBG" (if cfg.background != null then ''
          exec ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${cfg.background} "$@"
        '' else "exit 0"));
        termCMD = if cfg.tmuxDefault then ''${cfg.terminalStr} -e tx'' else ''${cfg.terminalStr}'';
        xtraTermCMD = if cfg.tmuxDefault then ''${cfg.terminalStr}'' else ''${cfg.terminalStr} -e tx'';
      in ''
        set $monMover ${monMover}
        set $fehBG ${fehBG}
        set $termCMD ${termCMD}
        set $xtraTermCMD ${xtraTermCMD}
        set $termSTR ${cfg.terminalStr}
      '' + builtins.readFile ../config + (if cfg.defaultLockerEnabled then ''
        exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
      '' else "") + cfg.appendedConfig);
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
        exec ${pkgs.i3lock}/bin/i3lock -t -i ${cfg.lockerBackground} "$@"
      '');
    in
    with pkgs; with pkgs.xfce; (if cfg.defaultLockerEnabled then [
      xss-lock
      i3lock #default i3 screen locker
    ] else []) ++ [
      i3status #default i3 status bar
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
