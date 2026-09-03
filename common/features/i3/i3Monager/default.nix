{ config, pkgs, lib, wlib, ... }@top: {
  options = {
    i3Monager = {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
      triggerFile = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "tmp" "i3monsMemory" "i3xrandrTriggerFile" ];
      };
      triggerType = lib.mkOption {
        default = "udev";
        type = lib.types.enum [
          null
          "udev"
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
  config.systemd.user.service.i3Monager = lib.mkIf config.i3Monager.enable {
    Unit = {
      Description = "i3Monager";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${import ./i3Monager.nix {
        inherit pkgs;
        toPass = {
          extra_path = with pkgs; [ coreutils-full xrandr i3 ];
          trigger_file_dir = "/" + builtins.concatStringsSep "/" (lib.init config.i3Monager.triggerFile);
          trigger_file_name = lib.last config.i3Monager.triggerFile;
          json_cache = null;
          config_script = config.i3Monager.configScript;
        };
      }}";
      # Restart = "on-failure";
      # RestartSec = "5";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  config.systemd.user.service.i3MonagerHotplugWatcher = lib.mkIf (config.i3Monager.enable && config.i3Monager.triggerType == "udev") (let
    monmon = pkgs.stdenv.mkDerivation {
      name = "udev-monitor";
      src = ./udev.c;
      buildInputs = [ pkgs.udev ];
      dontUnpack = true;
      buildPhase = "$CC -o $out -ludev  $src";
    };
  in {
    Unit = {
      Description = "i3Monager udev Hotplug Watcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${monmon} ${builtins.concatStringsSep " " config.i3Monager.triggerFile}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  });
}
