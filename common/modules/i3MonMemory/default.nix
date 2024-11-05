{ moduleNamespace, homeManager, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.i3MonMemory;
in {
  _file = ./default.nix;
  options = {
    ${moduleNamespace}.i3MonMemory = with lib.types; if homeManager then {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
      nameOfDir = lib.mkOption {
        default = "xrandrMemoryi3";
        type = str;
        description = "name of directory in $XDG_CONFIG_HOME for configuration scripts.";
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

          XmonBoot runs once at startup.

          Xprimary is ran each time a monitor is unplugged or plugged in.
          It is passed an array of all active displays as its arguments.

          Xothers is ran 1 time per each new screen plugged in,
          and is passed the name of the display added as its first argument.

          Xothers is executed before Xprimary.

          Items placed in $XDG_CONFIG_HOME/${cfg.nameOfDir}
          will override their nix provisioned counterparts with the same name.
          This behavior can be disabled by setting ${cfg.denyXDGoverride} to true.
        '') + ''

          If you do not include all the scripts,
          it will fill in the remaining with default scripts.
          The default scripts are not very good but very easy to
          understand and modify to configure for yourself.
          They are at ${./defaults}
        '';
        example = (lib.literalExpression ''monitorScriptDir = ${./monitorScripts}'');
      };
      denyXDGoverride = lib.mkEnableOption "dont override with scripts from $XDG_CONFIG_HOME";
      internalDependencies = lib.mkOption {
        default = with pkgs; [
          xorg.xrandr
          gawk
          coreutils-full
        ];
        type = listOf package;
        description = ''
          packages to be made available to all user xrandr scripts but not to path
          Can also take derivation string values.
        '';
        example = lib.literalExpression ''
          cfg.internalDependencies = with pkgs; [
            coreutils-full
            xorg.xrandr
            gawk
            "${jq}"
          ];
        '';
      };
    } else {
      # the trigger mechanism requires root set up a udev rule.
      enable = lib.mkEnableOption (lib.literalExpression ''
        echoes "$RANDOM" to /tmp/i3monsMemory/i3xrandrTriggerFile on udev rule trigger.
        This serves as the trigger mechanism for the user level services.
      '');
      trigger = lib.mkOption {
        default = "udev";
        type = lib.types.enum [ "udev" "Xlog" ];
        description = "type of system level trigger";
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    mkUserXrandrScript = scriptName: (let
      ifXDGthen = if cfg.denyXDGoverride then "false &&" else "true &&";
    in pkgs.writeShellScript "${scriptName}" (''
      export PATH="${lib.makeBinPath cfg.internalDependencies}:$PATH";
      userXDGcfg="''${XDG_CONFIG_HOME:-$HOME/.config}"
      ${ifXDGthen} if [[ -x $userXDGcfg/${cfg.nameOfDir}/${scriptName} ]]; then
        exec $userXDGcfg/${cfg.nameOfDir}/${scriptName} "$@"
      fi
    ''
    + (if cfg.monitorScriptDir != null
        && builtins.pathExists ("${cfg.monitorScriptDir}/${scriptName}")
      then builtins.readFile ("${cfg.monitorScriptDir}/${scriptName}")
      else builtins.readFile ./defaults/${scriptName})));

    xrandrPrimarySH = mkUserXrandrScript "Xprimary.sh";

    xrandrOthersSH = mkUserXrandrScript "Xothers.sh";

    XmonBootSH = mkUserXrandrScript "XmonBoot.sh";

    # Both the home manager and system modules MUST both point at this same file.
    # root will write a random number to it on monitor hotplug.
    # user service inotify script will be triggered and run the lua script.
    triggerFile = ''/tmp/i3monsMemory/i3xrandrTriggerFile'';

    inotifyScript = import ./inotify.nix {
      inherit pkgs triggerFile xrandrOthersSH xrandrPrimarySH;
    };

    udevAction = pkgs.writeShellScript "i3xrandrMemoryUDEV.sh" ''
      mkdir -p "$(dirname '${triggerFile}')"
      echo "$RANDOM" > ${triggerFile}
    '';

    XlogNotify = pkgs.writeShellScript "i3xrandrMemoryXlog.sh" ''
      export PATH="${pkgs.lib.makeBinPath (with pkgs; [ bash coreutils inotify-tools ])}:$PATH"
      LAST_LINES=$(wc -l < /var/log/X.0.log)
      inotifywait -e modify -m /var/log |
      while read -r directory events filename; do
        if [ "$filename" = "X.0.log" ]; then
          NEW_CONTENT="$(tail -n +"$((LAST_LINES+1))" /var/log/X.0.log)"
          LAST_LINES=$(wc -l < /var/log/X.0.log)
          if echo "$NEW_CONTENT" | grep -E "GPU-[0-9].*: (connected|disconnected)"; then
            bash -c '${udevAction}'
          fi
        fi
      done
    '';

  in (if homeManager then {
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
      };

      Install.WantedBy = [ "graphical-session.target" "default.target" ];
    };
  } else {
    systemd.services.i3MonTrigger = lib.mkIf (cfg.trigger == "Xlog") {
      description = "Writes to a triggerFile, triggering i3MonMemory";
      wantedBy = [ "graphical-session.target" "default.target" ];
      after = [ "graphical-session.target" "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash ${XlogNotify}";
        Restart = "always";
      };
    };
    services.udev = lib.mkIf (cfg.trigger == "udev") {
      enable = true;
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${udevAction}"
      '';
    };
  }));
}
