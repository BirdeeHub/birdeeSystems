{ config, pkgs, self, inputs, ... }: {
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
        # background = ./misc/CrabWarning.jpg;
      };
      defaultSession = "none+i3";
      # sessionCommands = ''
      # '';
    };
    desktopManager.xterm.enable = false;

    # Enable the i3 Desktop Environment.
    # desktopManager.xfce = {
    #     enable = true;
    #     noDesktop = true;
    #     enableXfwm = false;
    #     enableScreensaver = false;
    #   };
    # };
    windowManager.i3 = {
      enable = true;
      updateSessionEnvironment = true;
      configFile = builtins.toFile "config" (''
        exec --no-startup-id dbus-launch --exit-with-session i3
      '' + builtins.readFile ./config + ''
      '');
      extraSessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <${pkgs.writeText "Xresources" ''
          Xft.dpi: 100
        ''}
      '';
      extraPackages = let
        monMover = (pkgs.writeScriptBin "monWkspcCycle.sh"
          (builtins.readFile ./monWkspcCycle.sh));
        fehBG = (pkgs.writeScriptBin "fehBG" ''
          #!/bin/sh
          exec ${pkgs.feh}/bin/feh --bg-scale ${./misc/DogAteHomework.png} "$@"
        '');
        i3lock = (pkgs.writeScriptBin "i3lock" ''
          #!/bin/sh
          exec ${pkgs.i3lock}/bin/i3lock -t -i ${./misc/CrabWarning.png} "$@"
        '');
        i3status = (pkgs.writeScriptBin "i3status" ''
          #!/bin/sh
          exec ${pkgs.i3status}/bin/i3status --config ${builtins.toFile "i3bar" (builtins.readFile ./i3bar)} "$@"
        '');
      in
      with pkgs; with pkgs.xfce; [
        fehBG
        monMover
        jq
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        # dex
        xss-lock
        libnotify
        dmenu #application launcher most people use
        vlc
        pa_applet
        pavucontrol
        networkmanagerapplet
        lxappearance
        # i3blocks #if you are planning on using i3blocks over i3status
        xfce4-volumed-pulse
        hicolor-icon-theme
        xdg-desktop-portal
        tango-icon-theme
        xfce4-icon-theme
        glib # for gsettings
        gtk3.out # gtk-update-icon-cache
        gnome.gnome-themes-extra
        gnome.adwaita-icon-theme
        desktop-file-utils
        shared-mime-info # for update-mime-database
        polkit_gnome
        # Needed by Xfce's xinitrc script
        xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
        garcon
        libxfce4ui
        ristretto
        xfce4-power-manager
        xfce4-notifyd
        xfce4-screenshooter
        xfce4-taskmanager
      ];
    };
  };
  qt.platformTheme = "gtk";

  # How do I run a script when a monitor is connected/disconnected?
  # it doesnt even have to be this big script, even just xrandr --auto...
  # boot.kernelParams = let 
  #   randrMemory = (pkgs.writeScriptBin "randrMemory.sh" (''
  #       XRANDR_NEWMON_CONFIG=${configXrandrByOutput}
  #       XRANDR_ALWAYSRUN_CONFIG=${configPrimaryXrandr}
  #     ''+
  #     (builtins.readFile ./misc/i3xrandrMemory/i3autoXrandrMemory.sh)));
  #   configXrandrByOutput = (pkgs.writeScriptBin "configXrandrByOutput.sh"
  #     (builtins.readFile ./misc/i3xrandrMemory/configXrandrByOutput.sh));
  #   configPrimaryXrandr = (pkgs.writeScriptBin "configPrimaryDisplay.sh"
  #     (builtins.readFile ./misc/i3xrandrMemory/configPrimaryDisplay.sh));
  # in [
  #   ''"udev.rules=SUBSYSTEM==\"drm\", ACTION==\"change\", ENV{HOTPLUG}==\"1\", RUN+=\"${randrMemory}\""''
  # ];

  programs.thunar.enable = true;

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
