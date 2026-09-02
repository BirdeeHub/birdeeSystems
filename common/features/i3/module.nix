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
    config.globalPackages = with pkgs; [
      lm_sensors
      glib # for gsettings
      gtk3.out # gtk-update-icon-cache
      desktop-file-utils
      shared-mime-info # for update-mime-database
      polkit_gnome
      xdg-utils
      xdg-user-dirs
    ];
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
        persistify = (pkgs.writeShellScript "persistify.sh" ''
          export PATH="${lib.makeBinPath [ pkgs.libnotify pkgs.coreutils ]}:$PATH"
          ${builtins.readFile ./persistify.sh}
        '');
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
        brightness = pkgs.writeShellScript "brightness.sh" ''
          brightnessctl=${lib.escapeShellArg (lib.getExe pkgs.brightnessctl)}
          step=$1
          sign=$2
          icon=${./assets/brightness-up.svg}
          if [[ "$sign" == "-" ]]; then
            icon=${./assets/brightness-down.svg}
          fi
          $brightnessctl set $step%$sign && ${persistify} brightness -i "$icon" "$($brightnessctl -m | cut -d, -f4)"
        '';
      in ''
        exec --no-startup-id quickshell
        exec --no-startup-id ${lib.getExe pkgs.feh} --no-fehbg --bg-scale ${config.background}
        exec --no-startup-id ${lib.getExe pkgs.pasystray}
        exec --no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
        set $monMover ${monMover}
        set $persistify ${persistify}
        set $termCMD ${config.tmuxTerminalStr}
        set $termSTR ${config.tmuxlessTerm}
        set $bemenu ${inputs.self.outputs.wrappers.bemenu.wrap { inherit pkgs; }}/bin/bemenu-recency
        set $peek ${lib.getExe pkgs.peek}
        set $xfce4-screenshooter ${lib.getExe pkgs.xfce4-screenshooter}
        set $brightnesscmd ${brightness}
        ${config.prependedConfig}
      '' + builtins.readFile ./config + (
        if config.defaultLockerEnabled then
          ''
            exec --no-startup-id ${lib.getExe pkgs.xss-lock} --transfer-sleep-lock -- ${lib.getExe i3lock} --nofork
          ''
        else
            ""
      ) + config.appendedConfig;
    };
    config.flags."-c" = config.constructFiles.i3Config.path;
    config.runtimePkgs = with pkgs; [
      libnotify
      pavucontrol
      (inputs.self.outputs.wrappers.quickshell.wrap { inherit pkgs; i3status.cputemppath = config.cputemppath; })
    ];
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
