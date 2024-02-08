home-manager:
{ config, pkgs, lib, ... }: let
  cfg = config.birdeeMods.i3MonMemory;
in {
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
          ${dir} ━┳━━ XmonBoot.sh
                  ┣━━ Xprimary.sh
                  ┗━━ Xothers.sh

          If you do not include all the scripts, it will fill in default scripts.

          XmonBoot runs once at startup.

          Xprimary is ran each time a monitor is unplugged or plugged in.
          It is passed an array of all active displays as its arguments.

          Xothers is ran 1 time per each new screen plugged in,
          and is passed the name of the display added as its first argument.

          Items placed in $XDG_CONFIG_HOME/${cfg.nameOfDir}
          will override their nix provisioned counterparts with the same name.
          This behavior can be disabled by setting ${cfg.denyXDGoverride} to true.
        '');
        example = (lib.literalExpression ''monitorScriptDir = ${./monitorScripts}'');
      };
      denyXDGoverride = lib.mkEnableOption "dont override with scripts from $XDG_CONFIG_HOME";
      internalDependencies = lib.mkOption {
        default = {};
        type = attrsOf package;
        description = ''
          packages to be made available to all user xrandr scripts but not to path
          takes an attr set with programName = pkgs.programDerivation;
          Can also take derivation string values.
        '';
        example = lib.literalExpression ''
          cfg.internalDependencies = {
            xrandr = pkgs.xorg.xrandr;
            awk = pkgs.gawk;
            jq = "${pkgs.jq}";
          };
        '';
      };
    } else {
      # the trigger mechanism requires root set up a udev rule.
      enable = lib.mkEnableOption (lib.literalExpression ''
        echoes "$RANDOM" to /tmp/i3monsMemory/i3xrandrTriggerFile on udev rule trigger.
        This serves as the trigger mechanism for the user level services.
      '');
    };
  };

  config = lib.mkIf cfg.enable (let
    dependencies = {
      xrandr = pkgs.xorg.xrandr;
      awk = pkgs.gawk;
      jq = pkgs.jq;
    } // cfg.internalDependencies;
    mkScriptAliases = with builtins; packageSet: concatStringsSep "\n"
      (attrValues (mapAttrs (name: value: ''
          ${name}() {
            ${value}/bin/${name} "$@"
          }
      '') packageSet));
    ifXDGthen = if cfg.denyXDGoverride then "false &&" else "true &&";
    mkUserXrandrScript = scriptName: (pkgs.writeShellScript "${scriptName}.sh" (''
        ${mkScriptAliases dependencies}
        userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
        ${ifXDGthen} if [[ -x $userXDGcfg/${cfg.nameOfDir}/${scriptName}.sh ]]; then
          exec $userXDGcfg/${cfg.nameOfDir}/${scriptName}.sh
        fi
      ''
      + (if cfg.monitorScriptDir != null
          && builtins.pathExists ("${cfg.monitorScriptDir}/${scriptName}.sh")
        then builtins.readFile ("${cfg.monitorScriptDir}/${scriptName}.sh")
        else builtins.readFile ./defaults/${scriptName}.sh)));

    xrandrPrimarySH = mkUserXrandrScript "Xprimary";

    xrandrOthersSH = mkUserXrandrScript "Xothers";

    XmonBootSH = mkUserXrandrScript "XmonBoot";

    # I could expose this as an option at some point idk.
    # it doesnt have to be the same as triggerFile location
    # it just has to be readable and writeable
    # could be per user or the same for all,
    # it saves to ${userJsonCache}/$USER/userJsonCache.json
    # it just contains json with display names and workspace numbers
    userJsonCache = ''''${XDG_CACHE_HOME:-"$HOME/.cache"}/i3monsMemory'';

    # Unfortunately triggerFile must be hardcoded
    # otherwise it may not be the same for home-manager and system modules
    # maybe ill make it an option but make the description
    # a big warning that it must match if set.
    triggerFile = ''/tmp/i3monsMemory/i3xrandrTriggerFile'';

    inotifyScript = import ./inotify.nix {
      inherit pkgs triggerFile userJsonCache xrandrOthersSH xrandrPrimarySH;
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
        # ^ idk, if it fails its probably just gonna fail again
        # because it means user error. It gives better error message
        # when it only fails once.
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
