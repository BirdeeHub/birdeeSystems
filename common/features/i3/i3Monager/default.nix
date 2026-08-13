{ config, pkgs, lib, wlib, ... }@top: let
  triggerAction = dir: name: writeShellScript: writeShellScript "i3MonagerTrigger.sh" ''
    mkdir -p ${lib.escapeShellArg dir}
    echo "$RANDOM" > ${lib.escapeShellArg "${dir}/${name}"}
  '';
  inotifyScript = dir: name: config_script: import ./i3Monager.nix {
    inherit pkgs;
    toPass = {
      extra_path = with pkgs; [ coreutils-full xrandr i3 ];
      trigger_file_dir = dir;
      trigger_file_name = name;
      json_cache = null;
      config_script = config_script;
    };
  };
in {
  options = {
    i3Monager = {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
      triggerFileDir = lib.mkOption {
        type = lib.types.str;
        default = "/tmp/i3monsMemory";
      };
      triggerFileName = lib.mkOption {
        type = lib.types.str;
        default = "i3xrandrTriggerFile";
      };
      triggerType = lib.mkOption {
        default = "udev";
        type = lib.types.enum [
          null
          "udev"
          "Xlog"
        ];
        description = "type of system level trigger";
      };
      configScript = lib.mkOption {
        type = lib.types.raw;
        description = "lua script for monitor config ran by i3Monager on startup and monitor hotplug";
        default = ./default_config.lua;
      };
    };
  };
  config.systemd.user.service.i3MonagerMain = lib.mkIf config.i3Monager.enable {
    Unit = {
      Description = "i3MonagerMainService";
      After = [ "graphical-session.target" "i3MonagerBoot.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inotifyScript config.i3Monager.triggerFileDir config.i3Monager.triggerFileName config.i3Monager.configScript}";
      # Restart = "on-failure";
      # RestartSec = "5";
      X-ReloadIfChanged = false;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  config.systemd.user.service.i3MonagerBoot = lib.mkIf config.i3Monager.enable {
    Unit = {
      Description = "i3MonagerBootService";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${inotifyScript config.i3Monager.triggerFileDir config.i3Monager.triggerFileName config.i3Monager.configScript} boot";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  config.systemd.user.service.i3MonagerXlog= lib.mkIf (config.i3Monager.enable && config.i3Monager.triggerType == "Xlog") (let
  in {
    XlogNotify = pkgs.writeShellScript "i3xrandrMemoryXlog.sh" ''
      export PATH="${
        pkgs.lib.makeBinPath (
          with pkgs;
          [
            bash
            coreutils
            inotify-tools
          ]
        )
      }:$PATH"
      LAST_LINES=$(wc -l < /var/log/X.0.log)
      inotifywait -e modify -m /var/log |
      while read -r directory events filename; do
        if [ "$filename" = "X.0.log" ]; then
          NEW_CONTENT="$(tail -n +"$((LAST_LINES+1))" /var/log/X.0.log)"
          LAST_LINES=$(wc -l < /var/log/X.0.log)
          if echo "$NEW_CONTENT" | grep -E "GPU-[0-9].*: (connected|disconnected)"; then
            ${triggerAction config.i3Monager.triggerFileDir config.i3Monager.triggerFileName pkgs.writeShellScript}
          fi
        fi
      done
    '';
  });
  config.install.modules.nixos = { config, pkgs, ... }: let
    cfg = top.config.install.getWrapperConfig config;
    udevAction = triggerAction cfg.i3Monager.triggerFileDir cfg.i3Monager.triggerFileName pkgs.writeShellScript;
    enabled = cfg.i3Monager.enable && cfg.i3Monager.triggerType == "udev";
  in {
    services.udev = lib.mkIf enabled {
      enable = true;
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${udevAction}"
      '';
    };
  };
}
