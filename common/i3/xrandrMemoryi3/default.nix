{ home-manager ? false, ... }:
{ config, pkgs, self, inputs, lib, users, ... }: {
  options = {
    birdeeMods.i3.xrandrMemoryi3 = with lib.types; {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
      nameOfTempDir = lib.mkOption {
        default = "xrandrMemoryi3";
        type = str;
      };
      xrandrScriptByOutput = lib.mkOption {
        default = null;
        type = nullOr path;
      };
      primaryXrandrScript = lib.mkOption {
        default = null;
        type = nullOr path;
      };
    };
  };

  config = lib.mkIf config.birdeeMods.i3.xrandrMemoryi3.enable (let
    cfg = config.birdeeMods.i3.xrandrMemoryi3;

    randrMemory = let
      configXrandrByOutput = pkgs.writeScript "configXrandrByOutput.sh" (
      if cfg.xrandrScriptByOutput != null then ''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        '' + (builtins.readFile cfg.xrandrScriptByOutput)
      else "");
      configPrimaryXrandr = pkgs.writeScript "configPrimaryDisplay.sh" (
      if cfg.xrandrScriptByOutput != null then ''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        '' + (builtins.readFile cfg.primaryXrandrScript)
      else "");
    in
    (pkgs.writeScript "randrMemory.sh" (''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        bash() {
          ${pkgs.bash}/bin/bash "$@"
        }
        jq() {
          ${pkgs.jq}/bin/jq "$@"
        }
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        awk() {
          ${pkgs.gawk}/bin/awk "$@"
        }
        i3-msg() {
          ${pkgs.i3}/bin/i3-msg "$@"
        }
        i3msgpath=${pkgs.i3}/bin/i3-msg
        XRANDR_NEWMON_CONFIG=${configXrandrByOutput}
        XRANDR_ALWAYSRUN_CONFIG=${configPrimaryXrandr}
        #the script makes and uses this .json file. set it to an appropriate dir
        JSON_CACHE_PATH=/tmp/${cfg.nameOfTempDir}/users/$USER/userJsonCache.json
      ''+ (builtins.readFile ./i3autoXrandrMemory.sh)));
    # ruleLines = builtins.concatStringsSep "\n" (builtins.map (name: ''
    #     ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/${name}/.Xauthority", RUN+="${randrMemory}"
    # '') (cfg.enableFor));

    triggerFile = ''/tmp/${cfg.nameOfTempDir}/i3xrandrTriggerFile'';

    inotifyScript = import ./inotify.nix pkgs randrMemory triggerFile;

    udevAction = pkgs.writeShellScript "i3xrandrMemoryUDEV.sh" ''
      mkdir -p /tmp/${cfg.nameOfTempDir}
      echo "$RANDOM $RANDOM" > ${triggerFile}
    '';


  in (if home-manager
  then {
    systemd.user.services.i3xrandrMemory = {
      Unit = {
        Description = "i3xrandrMemory";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${inotifyScript}";
        Restart = "always";
      };

      Install.WantedBy = [ "graphical-session.target" "default.target" ];
    };
  }
  else {
    # How do I run a script when a monitor is connected/disconnected?
    # it doesnt even have to be this big script, even just xrandr --auto...
    # The script works when I run it from command line or i3 hotkey....
    # I cant even get these rules to echo to a file in /tmp
    services.udev = {
      enable = true;
        # ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm",  RUN+="${randrMemory}"
        # KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/birdee/.Xauthority", RUN+="${randrMemory}"
        # ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${randrMemory}"
        # ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", RUN+="${randrMemory}"
      # extraRules = ruleLines;
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${udevAction}"
      '';
    };
  }));
}
