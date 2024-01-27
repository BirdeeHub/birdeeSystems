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
        type = nullOr path;
        description = (lib.literalExpression ''
          the absolute path to a directory containing 3 scripts
          which must be of specific names.
          i.e.
          ${dir} ━┳━━ Xprimary.sh
                  ┣━━ XmonBoot.sh
                  ┗━━ Xothers.sh

          If you do not include all the scripts, it will fill in default scripts.

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
        echoes "$RANDOM" to /tmp/i3monsMemory/i3xrandrTriggerFile on udev rule trigger.
        This serves as the trigger mechanism for the user level services.
      '');
    };
  };

  config = lib.mkIf config.birdeeMods.i3MonMemory.enable (let
    cfg = config.birdeeMods.i3MonMemory;
    ifXDG = if cfg.denyXDGoverride then "false &&" else "true &&";
    mkUserXrandrScript = scriptName: (pkgs.writeShellScript "${scriptName}.sh" (''
        xrandr() {
          ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        awk() {
          ${pkgs.gawk}/bin/awk "$@"
        }
        userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
        ${ifXDG} if [[ -x $userXDGcfg/${cfg.nameOfDir}/${scriptName}.sh ]]; then
          exec $userXDGcfg/${cfg.nameOfDir}/${scriptName}.sh
        fi
      ''
      + (if cfg.monitorScriptDir != null
          && builtins.pathExists ("${cfg.monitorScriptDir}/${scriptName}.sh")
        then builtins.readFile ("${cfg.monitorScriptDir}/${scriptName}.sh")
        else builtins.readFile ./defaults/${scriptName}.sh)));

    xrandrPrimarySH = mkUserXrandrScript "Xprimary";

    xrandrOthersSH =mkUserXrandrScript "Xothers";

    XmonBootSH = mkUserXrandrScript "XmonBoot";

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
        PartOf = [ "graphical-session.target" ];
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
