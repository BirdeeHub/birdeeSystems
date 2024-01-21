{ home-manager ? false, ... }:
{ config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.i3.xrandrMemoryi3 = with lib.types; {
      enable = lib.mkEnableOption "an auto-run workspace switcher on monitor hotplug";
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
      #!/usr/bin/env bash
  config = lib.mkIf config.birdeeMods.i3.xrandrMemoryi3.enable (let
    cfg = config.birdeeMods.i3.xrandrMemoryi3;
    randrMemory = let
      configXrandrByOutput = pkgs.writeScript "configXrandrByOutput.sh" (
      if cfg.xrandrScriptByOutput != null then ''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        alias xrandr='${pkgs.xorg.xrandr}/bin/xrandr'
        '' + (builtins.readFile cfg.xrandrScriptByOutput)
      else "");
      configPrimaryXrandr = pkgs.writeScript "configPrimaryDisplay.sh" (
      if cfg.xrandrScriptByOutput != null then ''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        alias xrandr='${pkgs.xorg.xrandr}/bin/xrandr'
        '' + (builtins.readFile cfg.primaryXrandrScript)
      else "");
    in
    (pkgs.writeScript "randrMemory.sh" (''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        alias jq='${pkgs.jq}/bin/jq'
        alias xrandr='${pkgs.xorg.xrandr}/bin/xrandr'
        alias awk='${pkgs.gawk}/bin/awk'
        alias i3-msg='${pkgs.i3}/bin/i3-msg'
        XRANDR_NEWMON_CONFIG=${configXrandrByOutput}
        XRANDR_ALWAYSRUN_CONFIG=${configPrimaryXrandr}
      ''+ (builtins.readFile ./i3autoXrandrMemory.sh)));
    xrandrMemory = pkgs.writeScriptBin "xrandrMemory" (builtins.readFile randrMemory);
  in {
    environment.systemPackages = [ xrandrMemory ];
    # How do I run a script when a monitor is connected/disconnected?
    # it doesnt even have to be this big script, even just xrandr --auto...
    # The script works when I run it from command line or i3 hotkey....
    # I cant even get these rules to echo to a file in /tmp
    services.udev = {
      enable = true;
        # ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm",  RUN+="${randrMemory}"
        # KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/birdee/.Xauthority", RUN+="${randrMemory}"
        # ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${randrMemory}"
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/birdee/.Xauthority", RUN+="${randrMemory}"
      '';
    };
  });
}
