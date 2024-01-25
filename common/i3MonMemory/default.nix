home-manager:
{ config, pkgs, lib, ... }: {
  options = {
    birdeeMods.i3MonMemory = with lib.types; if home-manager then {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
      nameOfDir = lib.mkOption {
        default = "xrandrMemoryi3";
        type = str;
        description = "name of directory in $XDG_CONFIG_HOME";
      };
      monitorScriptDir = lib.mkOption {
        default = null;
        type = nullOr (oneOf [ str path ]);
        description = (lib.literalExpression ''
          the absolute path to a directory containing 3 scripts
          which must be of specific names.
          i.e.
          ${dir} ━┳━━ Xprimary.sh
                  ┣━━ XmonBoot.sh
                  ┗━━ Xothers.sh

          If you enter a path typed value and do not include all the scripts,
          it will add default scripts.

          Items placed in $XDG_CONFIG_HOME/${cfg.nameOfDir}
          will override their nix provisioned counterparts with the same name.
          This behavior can be disabled by setting ${cfg.denyXDGoverride} to true.
        '');
        example = (lib.literalExpression ''monitorScriptDir = ${./monitorScripts}'');
      };
      denyXDGoverride = lib.mkEnableOption "dont override with scripts from $XDG_CONFIG_HOME";
    } else {
      # the trigger mechanism requires root set up a udev rule.
      enable = lib.mkEnableOption (lib.literalExpression ''
      prints "$RANDOM" to /tmp/${cfg.nameOfDir}/i3xrandrTriggerFile on udev rule trigger
      '');
    };
  };

  config = lib.mkIf config.birdeeMods.i3MonMemory.enable (let
    cfg = config.birdeeMods.i3MonMemory;
    ifXDG = if cfg.denyXDGoverride then "false &&" else "true &&";
    bootupMonitorScript = pkgs.writeShellScript "defaultBootupMonitorScript.sh" (''
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
        ${ifXDG} if [[ -x $userXDGcfg/${cfg.nameOfDir}/XmonBoot.sh ]]; then
          exec $userXDGcfg/${cfg.nameOfDir}/XmonBoot.sh
        fi
      ''
      + (if cfg.monitorScriptDir != null
          && builtins.pathExists ("${cfg.monitorScriptDir}/XmonBoot.sh")
        then builtins.readFile ("${cfg.monitorScriptDir}/XmonBoot.sh")
        else builtins.readFile ./defaults/MonBoot.sh));

    configXrandrByOutput = pkgs.writeShellScript "configXrandrByOutput.sh" (''
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
        ${ifXDG} if [[ -x $userXDGcfg/${cfg.nameOfDir}/Xothers.sh ]]; then
          exec $userXDGcfg/${cfg.nameOfDir}/Xothers.sh
        fi
      ''
      + (if cfg.monitorScriptDir != null
          && builtins.pathExists ("${cfg.monitorScriptDir}/Xothers.sh")
        then builtins.readFile ("${cfg.monitorScriptDir}/Xothers.sh")
        else builtins.readFile ./defaults/MonOthers.sh));

    configPrimaryXrandr = pkgs.writeShellScript "configPrimaryDisplay.sh" (''
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
        ${ifXDG} if [[ -x $userXDGcfg/${cfg.nameOfDir}/Xprimary.sh ]]; then
          exec $userXDGcfg/${cfg.nameOfDir}/Xprimary.sh
        fi
      ''
      + (if cfg.monitorScriptDir != null
          && builtins.pathExists ("${cfg.monitorScriptDir}/Xprimary.sh")
        then builtins.readFile ("${cfg.monitorScriptDir}/Xprimary.sh")
        else builtins.readFile ./defaults/MonPrimary.sh));

    xrandrPrimarySH = if builtins.isString cfg.monitorScriptDir
      then "${cfg.monitorScriptDir}/Xprimary.sh"
      else "${configPrimaryXrandr}";

    xrandrOthersSH = if builtins.isString cfg.monitorScriptDir
      then "${cfg.monitorScriptDir}/Xothers.sh"
      else "${configXrandrByOutput}";

    XmonBootSH = if builtins.isString cfg.monitorScriptDir
      then "${cfg.monitorScriptDir}/XmonBoot.sh"
      else "${bootupMonitorScript}";

    triggerFile = ''/tmp/i3monsMemory/i3xrandrTriggerFile'';

    inotifyScript = import ./inotify.nix {
      inherit pkgs triggerFile xrandrOthersSH xrandrPrimarySH;
      inherit (cfg) nameOfDir denyXDGoverride;
    };

    udevAction = pkgs.writeShellScript "i3xrandrMemoryUDEV.sh" ''
      mkdir -p /tmp/i3monsMemory/
      echo "$RANDOM" > ${triggerFile}
    '';


  in (if home-manager
  then {
    systemd.user.services.i3xrandrMemory = {
      Unit = {
        Description = "i3MemoryMon";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${inotifyScript}";
        Restart = "always";
      };

      Install.WantedBy = [ "graphical-session.target" "default.target" ];
    };
    systemd.user.services.i3xrandrBootUp = {
      Unit = {
        Description = "i3monBoot";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${XmonBootSH}";
        # Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" "default.target" ];
    };
  }
  else {
    services.udev = {
      enable = true;
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${udevAction}"
      '';
    };
  }));
}
