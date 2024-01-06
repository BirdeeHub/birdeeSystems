{ config, pkgs, self, inputs, ... }: let
    jq = pkgs.writeScript "jq" (''
      #!/usr/bin/env bash
      exec ${pkgs.jq}/bin/jq "$@"
    '');
    xrandr = pkgs.writeScript "xrandr" (''
      #!/usr/bin/env bash
      exec ${pkgs.xorg.xrandr}/bin/xrandr "$@"
    '');
    randrMemory = let
      configXrandrByOutput = pkgs.writeScript "configXrandrByOutput.sh" (''
        #!/usr/bin/env bash
        xrandr=${xrandr}
        '' + (builtins.readFile ./mon/configXrandrByOutput.sh));
      configPrimaryXrandr = pkgs.writeScript "configPrimaryDisplay.sh" (''
        #!/usr/bin/env bash
        xrandr=${xrandr}
        '' + (builtins.readFile ./mon/configPrimaryDisplay.sh));
    in
    (pkgs.writeScript "randrMemory.sh" (''
        #!/usr/bin/env bash
        jq=${jq}
        xrandr=${xrandr}
        XRANDR_NEWMON_CONFIG=${configXrandrByOutput}
        XRANDR_ALWAYSRUN_CONFIG=${configPrimaryXrandr}
      ''+ (builtins.readFile ./mon/i3autoXrandrMemory.sh)));
in {

  # How do I run a script when a monitor is connected/disconnected?
  # it doesnt even have to be this big script, even just xrandr --auto...
  services.udev = {
    enable = true;
    extraRules = ''
      ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${randrMemory}"
    '';
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    dpi = 100;

    displayManager = {
      lightdm = {
        enable = true;
        greeter = {
          enable = true;
        };
        extraConfig = ''
        '';
        # background = ./misc/DogAteHomework.png;
      };
      defaultSession = "none+i3";
      # sessionCommands = ''
      # '';
    };
    desktopManager.xterm.enable = false;

    # Enable the i3 Desktop Environment.
    windowManager.i3 =
    {
      enable = true;
      updateSessionEnvironment = true;
      configFile = let
        monMover = (pkgs.writeScript "monWkspcCycle.sh" (''
          #!/usr/bin/env bash
          jq=${jq}
          xrandr=${xrandr}
        '' + (builtins.readFile ./mon/monWkspcCycle.sh) + ''
        ''));
        fehBG = (pkgs.writeScript "fehBG" ''
          #!/bin/sh
          exec ${pkgs.feh}/bin/feh --bg-scale ${./misc/rooftophang.png} "$@"
        '');
        i3status = (pkgs.writeScript "i3status" ''
          #!/bin/sh
          exec ${pkgs.i3status}/bin/i3status --config ${builtins.toFile "i3bar" (builtins.readFile ./i3bar)} "$@"
        '');
        bootUpMonScript = pkgs.writeScript "bootUpMon.sh" (''
          #!/usr/bin/env bash
          xrandr=${xrandr}
        '' + (builtins.readFile ./mon/bootUpMonitorScript.sh));
      in "${ pkgs.writeText "config" (''
          set $i3status ${i3status}
          set $monMover ${monMover}
          set $fehBG ${fehBG}
          set $randrMemory ${randrMemory}
          set $xrandr ${xrandr}
          set $bootUpMonScript ${bootUpMonScript}
        '' + builtins.readFile ./config + ''
        '') }";
      extraSessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
          Xft.dpi: 100
        ''}
      '';
      extraPackages = let
        i3lock = (pkgs.writeScriptBin "i3lock" ''
          #!/bin/sh
          exec ${pkgs.i3lock}/bin/i3lock -t -i ${./misc/DogAteHomework.png} "$@"
        '');
      in
      with pkgs; with pkgs.xfce; [
        # i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        # dex
        xss-lock
        libnotify
        dmenu #application launcher most people use
        pa_applet
        pavucontrol
        networkmanagerapplet
        lxappearance
        # i3blocks #if you are planning on using i3blocks over i3status
        xfce4-volumed-pulse
        hicolor-icon-theme
        tango-icon-theme
        xfce4-icon-theme
        glib # for gsettings
        gtk3.out # gtk-update-icon-cache
        gnome.gnome-themes-extra
        gnome.adwaita-icon-theme
        desktop-file-utils
        shared-mime-info # for update-mime-database
        polkit_gnome
        xdg-utils
        # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
        garcon
        libxfce4ui
        xfce4-power-manager
        xfce4-notifyd
        xfce4-screenshooter
        xfce4-taskmanager
      ];
    };
  };
  qt.platformTheme = "gtk";

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";

  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  services.dbus.enable = true;
  services.xserver.updateDbusEnvironment = true;
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

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
    # uncomment to fix i3blocks
    # environment.pathsToLink = [ "/libexec" ];
  ];
}
