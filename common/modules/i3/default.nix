{ moduleNamespace, homeManager, inputs, util, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.i3;
in {
  _file = ./default.nix;
  imports = [
  ];
  options = {
    ${moduleNamespace}.i3 = with lib.types; {
      enable = lib.mkEnableOption "birdee's i3 configuration";
      dmenu = {
        terminalStr = lib.mkOption {
          default = ''${config.wrappers.wezterm.wrapper}/bin/wezterm'';
          type = str;
        };
      };
      tmuxTerminalStr = lib.mkOption {
        default = ''${config.wrappers.wezterm.wrap { withLauncher = true; }}/bin/wezterm'';
        type = str;
        description = "mod + enter";
      };
      tmuxlessTerm = lib.mkOption {
        default = ''${config.wrappers.wezterm.wrapper}/bin/wezterm'';
        type = str;
        description = "mod + shift + enter";
      };
      extraSessionCommands = lib.mkOption {
        default = null;
        type = nullOr str;
      };
      updateDbusEnvironment = lib.mkEnableOption "updating of dbus session environment";
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
        default = ./misc/rooftophang.png;
        type = nullOr path;
      };
      lockerBackground = lib.mkOption {
        default = ./misc/DogAteHomework.png;
        type = nullOr path;
      };
      cputemppath = lib.mkOption {
        default = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
        type = str;
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    i3Config = (let
        monMover = (pkgs.writeShellScript "monWkspcCycle.sh" ''
          jq() {
            ${pkgs.jq}/bin/jq "$@"
          }
          xrandr() {
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
          }
          ${builtins.readFile ./monWkspcCycle.sh}
        '');
        fehBG = (pkgs.writeShellScript "fehBG" (if cfg.background != null then ''
          exec ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${cfg.background} "$@"
        '' else "exit 0"));
      in ''
          set $monMover ${monMover}
          set $fehBG ${fehBG}
          set $termCMD ${cfg.tmuxTerminalStr}
          set $termSTR ${cfg.tmuxlessTerm}
          ${cfg.prependedConfig}
        '' + builtins.readFile ./config + (if cfg.defaultLockerEnabled then ''
          exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
        '' else "") + cfg.appendedConfig);

    i3packagesList = (let
      dmenu = pkgs.writeShellScriptBin "dmenu_run" (/* bash */''
        dmenu() {
          ${pkgs.dmenu}/bin/dmenu "$@"
        }
        dmenu_path() {
          ${pkgs.dmenu}/bin/dmenu_path "$@"
        }
        TERMINAL=${cfg.dmenu.terminalStr}
      '' + (builtins.readFile ./dmenu_recency.sh));
      dmenuclr_recent = ''${pkgs.writeShellScriptBin "dmenuclr_recent" ''
        cachedir=''${XDG_CACHE_HOME:-"$HOME/.cache"}
        cache="$cachedir/dmenu_recent"
        rm $cache
      ''}'';
      i3status = util.wlib.evalPackage {
        imports = [ ./i3bar.nix ];
        inherit pkgs;
        inherit (cfg) cputemppath;
      };
      i3lock = util.wlib.wrapPackage {
        inherit pkgs;
        package = pkgs.i3lock;
        addFlag = [
          [ "-t" "-i" cfg.lockerBackground ]
        ];
      };
    in
    with pkgs; (if cfg.defaultLockerEnabled then [
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

    xresources = pkgs.writeText "Xresources" ''
      XTerm*termName: xterm-256color
      XTerm*faceName: FiraMono Nerd Font
      XTerm*faceSize: 12
      XTerm*background: black
      XTerm*foreground: white
      XTerm*title: XTerm
      XTerm*loginShell: true
    '';

    xtraSesCMDs = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xresources}

      ${if cfg.extraSessionCommands == null then "" else cfg.extraSessionCommands}
    '';

  in (if homeManager then {

    xsession.enable = true;
    xsession.scriptPath = ".xsession";
    xsession.initExtra = ''${lib.optionalString cfg.updateDbusEnvironment ''
      systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all || true
    ''}
      ${xtraSesCMDs}
    '';
    xsession.windowManager.i3 = {
      enable = true;
      config = null;
      extraConfig = i3Config;
    };

    # home.activation = {
    #   myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     run ln -s $VERBOSE_ARG \
    #       ${builtins.toPath ./link-me-directly} $HOME
    #   '';
    # };

    home.packages = i3packagesList;

  } else {

    # system.activationScripts.something.text = ''
    # '';

    services.displayManager.defaultSession = lib.mkOverride 1001 "none+i3";
    services.xserver.windowManager.i3 = {
      enable = true;
      updateSessionEnvironment = cfg.updateDbusEnvironment;
      configFile = "${ pkgs.writeText "config" i3Config }";
      extraSessionCommands = xtraSesCMDs;
    };
    environment.systemPackages = i3packagesList;
    # services.xserver.updateDbusEnvironment = cfg.updateDbusEnvironment;

  }));
}
