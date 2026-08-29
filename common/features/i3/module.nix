{
  inputs,
  util,
  ...
}: {
  flake.wrappers.i3 = { pkgs, lib, wlib, config, ... }@top: let
  in {
    imports = [ wlib.modules.default wlib.modules.systemd ./i3Monager ];
    options = let
      inherit (lib.types) nullOr str bool path listOf raw;
    in {
      tmuxTerminalStr = lib.mkOption {
        default = "${inputs.self.outputs.wrappers.wezterm.wrap { inherit pkgs; withLauncher = true; }}/bin/wezterm";
        type = str;
        description = "mod + enter";
      };
      tmuxlessTerm = lib.mkOption {
        default = "${inputs.self.outputs.wrappers.wezterm.wrap { inherit pkgs; }}/bin/wezterm";
        type = str;
        description = "mod + shift + enter";
      };
      extraSessionCommands = lib.mkOption {
        default = null;
        type = nullOr str;
      };
      updateDbusEnvironment = lib.mkOption {
        description = "Enable updating of dbus session environment";
        type = bool;
        default = false;
      };
      setInstallOption = lib.mkOption {
        type = bool;
        default = true;
        description = "set install option to make this wrapper used for the session";
      };
      defaultLockerEnabled = lib.mkOption {
        default = true;
        type = bool;
        description = "default locker = i3lock + xss-lock";
      };
      prependedConfig = lib.mkOption {
        default = "";
        type = str;
      };
      appendedConfig = lib.mkOption {
        default = "";
        type = str;
      };
      background = lib.mkOption {
        default = ./assets/rooftophang.png;
        type = nullOr path;
      };
      lockerBackground = lib.mkOption {
        default = ./assets/DogAteHomework.png;
        type = nullOr path;
      };
      cputemppath = lib.mkOption {
        default = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
        type = str;
      };
      globalPackages = lib.mkOption {
        type = listOf raw;
        default = [];
        description = "additional global packages to install when installed on nixos or home manager";
      };
      installGlobalPackages = lib.mkOption {
        type = bool;
        default = true;
        description = "install globalPackages";
      };
    };
    config.globalPackages = let
      i3lock = util.wlib.wrapPackage {
        inherit pkgs;
        package = pkgs.i3lock;
        addFlag = [
          [
            "-t"
            "-i"
            config.lockerBackground
          ]
        ];
      };
    in
    lib.optionals config.defaultLockerEnabled [
      pkgs.xss-lock
      i3lock # default i3 screen locker
    ] ++ (with pkgs; [
      libnotify
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
      # xfce4-notifyd
      xfce4-screenshooter
      xfce4-taskmanager
      qt5.qtquickcontrols2
      qt5.qtgraphicaleffects
      # libXinerama
      # dex
      # hicolor-icon-theme
      # tango-icon-theme
      # xfce4-icon-theme
      # gnome.gnome-themes-extra
      # gnome.adwaita-icon-theme
    ]);
    config.package = pkgs.i3;
    config.install.modules.nixos = { pkgs, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
      security.pam.services.i3lock.enable = cfg.defaultLockerEnabled && cfg.enable;
      services.xserver.windowManager.session = lib.optionals (cfg.enable && cfg.setInstallOption) [
        {
          name = "i3";
          start = ''
            ${lib.getExe cfg.wrapper} &
            waitPIT=$!
          '';
        }
      ];
      services.displayManager.defaultSession = lib.mkIf (cfg.enable && cfg.setInstallOption) (lib.mkOverride 1001 "none+i3");
      environment.systemPackages = lib.optionals (cfg.enable && cfg.installGlobalPackages) cfg.globalPackages;
    };
    config.install.modules.homeManager = { pkgs, config, ... }: let
      cfg = top.config.install.getWrapperConfig config;
    in {
      # home.activation = {
      #   myActivationAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
      #     run ln -s $VERBOSE_ARG \
      #       ${builtins.toPath ./link-me-directly} $HOME
      #   '';
      # };
      xsession.enable = (cfg.enable && cfg.setInstallOption);
      xsession.scriptPath = lib.optionalString (cfg.enable && cfg.setInstallOption) ".xsession";
      xsession.windowManager.command = lib.optionalAttrs (cfg.enable && cfg.setInstallOption) (lib.getExe cfg.wrapper);
      home.packages = lib.optionals (cfg.enable && cfg.installGlobalPackages) cfg.globalPackages;
    };
    config.constructFiles.i3Config = {
      relPath = "nix-generated-i3-config";
      content = let
        monMover = (pkgs.writeShellScript "monWkspcCycle.sh" ''
          export PATH="${lib.makeBinPath [ pkgs.jq pkgs.xrandr ]}:$PATH"
          ${builtins.readFile ./monWkspcCycle.sh}
        '');
        fehBG = (
          pkgs.writeShellScript "fehBG" (
            if config.background != null then
              ''
                exec ${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${config.background} "$@"
              ''
            else
              "exit 0"
          )
        );
      in ''
        set $monMover ${monMover}
        set $fehBG ${fehBG}
        set $termCMD ${config.tmuxTerminalStr}
        set $termSTR ${config.tmuxlessTerm}
        set $quickshell ${lib.getExe (inputs.self.outputs.wrappers.quickshell.wrap { inherit pkgs; i3status.cputemppath = config.cputemppath; })}
        set $pasystray ${lib.getExe pkgs.pasystray} --key-grabbing
        set $bemenu ${inputs.self.outputs.wrappers.bemenu.wrap { inherit pkgs; }}/bin/bemenu-recency
        ${config.prependedConfig}
      '' + builtins.readFile ./config + (
        if config.defaultLockerEnabled then
          ''
            exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
          ''
        else
            ""
      ) + config.appendedConfig;
    };
    config.flags."-c" = config.constructFiles.i3Config.path;
    config.runShell = let
      xresources = pkgs.writeText "Xresources" ''
        XTerm*termName: xterm-256color
        XTerm*faceName: FiraMono Nerd Font
        XTerm*faceSize: 12
        XTerm*background: black
        XTerm*foreground: white
        XTerm*title: XTerm
        XTerm*loginShell: true
      '';
    in [
      ''
        ${lib.optionalString config.updateDbusEnvironment ''
          systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
          ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all || true
        ''}
        ${pkgs.xrdb}/bin/xrdb -merge ${xresources}
        ${if config.extraSessionCommands == null then "" else config.extraSessionCommands}
      ''
    ];
  };
}
