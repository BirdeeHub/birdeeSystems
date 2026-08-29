{inputs, ...}:
{
  flake.wrappers.quickshell = { config, lib, wlib, pkgs, ... }: {
    imports = [ wlib.wrapperModules.quickshell ];
    options.i3status = lib.mkOption {
      type = wlib.types.subWrapperModule {
        imports = [ inputs.self.wrapperModules.i3status ];
        config.pkgs = pkgs;
        config.general.output_format = "i3bar";
      };
    };
    config.configFile = ''
      //@ pragma UseQApplication
      import Quickshell
      import "bar"
      Scope {
        My3Bar {}
        NotifyDeez {}
      }
    '';
    options.notifyConfig = lib.mkOption {
      type = wlib.types.attrsRecursive;
    };
    config.notifyConfig = {
      fontSize = 14;
      timeout = 5000;
    };
    options.colors = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
    };
    config.colors = {
      darkest = "black";
      darker = "#1a1b26";
      dark = "#292F34";
      medium = "#3e4452";
      light = "#047180";
      bright = "#80a0ff";
      lightest = "white";
      good = "#9ECE6A";
      warn = "#F2D674";
      alert = "#BA02F2";
    };
    options.barConfig = lib.mkOption {
      type = wlib.types.attrsRecursive;
    };
    config.barConfig = {
      fontSize = 11;
      height = 15;
      battery = {
        width = 50;
        heightPercent = 90;
        warnPercent = 60;
        critPercent = 30;
      };
      workspaces = {
        width = 20;
        spacing = 4;
        heightPercent = 90;
      };
      tray = {
        iconPercentOfHeight = 90;
        spacing = 8;
        rightMargin = 4;
      };
      stats = {
        isSway = false;
        i3status = lib.getExe config.i3status.wrapper;
        leftPadding = 8;
        rightPadding = 8;
      };
    };
    config.constructFiles.configJS = {
      relPath = dirOf config.constructFiles.generatedConfig.relPath + "/config.js";
      content = ''
        const notify = ${builtins.toJSON config.notifyConfig}
        const colors = ${builtins.toJSON config.colors}
        const bar = ${builtins.toJSON config.barConfig}
      '';
    };
    config.buildCommand.mkCfg = ''
      ${lib.getExe pkgs.lndir} ${./config} ${config.generated.placeholder}
    '';
  };
}
