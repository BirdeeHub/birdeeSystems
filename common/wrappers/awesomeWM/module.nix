{ inputs, util, ... }:
{
  flake.wrappers.somewm =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ inputs.self.wrapperModules.awesomeWM ];
      config.package = lib.mkForce inputs.somewm.packages.${pkgs.stdenv.hostPlatform.system}.default;
      config.info.modkey = lib.mkForce "Mod1";
      config.info.isX11 = lib.mkForce false;
    };
  flake.wrappers.awesomeWM =
    {
      config,
      pkgs,
      lib,
      wlib,
      ...
    }:
    {
      imports = [ ./. ];
      config.package = pkgs.awesome.overrideAttrs (oa: {
        version = inputs.awesome-git.rev;
        src = inputs.awesome-git;
        patches = [ ];
        cmakeFlags = (oa.cmakeFlags or [ ]) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
        postPatch = ''
          patchShebangs tests/examples/_postprocess.lua
        '';
      });
      config.init = ''
        require('birdee')
      '';
      config.extraLuaPaths = [
        ./lua
        (pkgs.runCommand "layout-machi" { }
          "mkdir -p $out && cp -r ${inputs.layout-machi} $out/layout-machi"
        )
      ];
      config.env.XCURSOR_THEME = "Adwaita";
      config.env.XCURSOR_SIZE = toString 24;
      config.info = {
        isX11 = true;
        bemenu = (inputs.self.wrappers.bemenu.apply { inherit pkgs; }).constructFiles.bemenu-recency.outPath;
        modkey = "Mod4";
        terminal = lib.getExe (
          inputs.self.wrappers.wezterm.wrap {
            inherit pkgs;
            withLauncher = true;
          }
        );
        terminalSTR = lib.getExe (inputs.self.wrappers.wezterm.wrap { inherit pkgs; });
        flake_svg = ./nix-flake.svg;
        editor = inputs.self.wrappers.neovim.wrap { inherit pkgs; };
        wallpaper = ../../modules/i3/misc/rooftophang.png;
        left = "h";
        down = "j";
        up = "k";
        right = "l";
        gaps_inner = 5;
        gaps_outer = 1;
        smart_gaps = true;
        smart_borders = "no_gaps";
        default_border_width = 3;
        default_floating_border_width = 1;
      };
      config.extraPackages =
        let
          i3lock = util.wlib.wrapPackage {
            inherit pkgs;
            package = pkgs.i3lock;
            addFlag = [
              [
                "-t"
                "-i"
                ../../modules/i3/misc/DogAteHomework.png
              ]
            ];
          };
        in
        with pkgs;
        [
          xss-lock
          i3lock # default i3 screen locker
          i3status # default i3 status bar
          libnotify
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
          libsForQt5.qt5.qtquickcontrols2
          libsForQt5.qt5.qtgraphicaleffects
          # libXinerama
          # dex
          # hicolor-icon-theme
          # tango-icon-theme
          # xfce4-icon-theme
          # gnome.gnome-themes-extra
          # gnome.adwaita-icon-theme
        ];
    };
  flake.modules.nixos.awesomeWM =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.wrappers.awesomeWM.enable) {
        services.xserver.enable = true;
        security.pam.services.i3lock.enable = true;
        services.xserver.desktopManager.xterm.enable = false;
        services.displayManager.defaultSession = lib.mkForce "none+myawesome";
        services.xserver.windowManager.session = [
          {
            name = "myawesome";
            start = ''
              ${lib.getExe config.wrappers.awesomeWM.wrapper} &
              waitPID=$!
            '';
          }
        ];
      };
    };
}
