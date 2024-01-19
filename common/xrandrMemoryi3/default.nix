{ config, pkgs, self, inputs, lib, ... }: {
  options = {
    birdeeMods.xrandrMemoryi3 = with lib.types; {
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
  config = lib.mkIf config.birdeeMods.xrandrMemoryi3.enable (let
    cfg = config.birdeeMods.xrandrMemoryi3;
    jq = pkgs.writeScript "jq" (''
      #!/usr/bin/env bash
      exec ${pkgs.jq}/bin/jq $@
    '');
    xrandr = pkgs.writeScript "xrandr" (''
      #!/usr/bin/env bash
      exec ${pkgs.xorg.xrandr}/bin/xrandr $@
    '');
    randrMemory = let
      configXrandrByOutput = pkgs.writeScript "configXrandrByOutput.sh" (
      if cfg.xrandrScriptByOutput == null then ''
        #!/usr/bin/env bash
        xrandr=${xrandr}
        '' + (builtins.readFile cfg.xrandrScriptByOutput)
      else "");
      configPrimaryXrandr = pkgs.writeScript "configPrimaryDisplay.sh" (
      if cfg.xrandrScriptByOutput == null then ''
        #!/usr/bin/env bash
        xrandr=${xrandr}
        '' + (builtins.readFile cfg.primaryXrandrScript)
      else "");
    in
    (pkgs.writeScript "randrMemory.sh" (''
        #!/usr/bin/env bash
        jq=${jq}
        xrandr=${xrandr}
        XRANDR_NEWMON_CONFIG=${configXrandrByOutput}
        XRANDR_ALWAYSRUN_CONFIG=${configPrimaryXrandr}
      ''+ (builtins.readFile ./i3autoXrandrMemory.sh)));
  in {
    # How do I run a script when a monitor is connected/disconnected?
    # it doesnt even have to be this big script, even just xrandr --auto...
    services.udev = {
      enable = true;
        # ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm",  RUN+="${pkgs.xorg.xrandr}/bin/xrandr --auto"
      extraRules = ''
        ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${randrMemory}"
      '';
    };
  });
}