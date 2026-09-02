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
    config.configFile = /*qml*/ ''
      //@ pragma UseQApplication
      import Quickshell
      import Quickshell.Io
      import "bar"
      Scope {
        My3Bar {}
        NotifyDeez {}
        IpcHandler {
          target: "top"
          function quit(): void {
              Qt.quit()
          }
        }
      }
    '';
    options.settings = lib.mkOption {
      type = wlib.types.attrsRecursive;
    };
    config.settings.notify = {
      fontSize = 14;
      timeout = 5000;
    };
    config.settings.colors = {
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
    config.settings.bar = {
      fontSize = 11;
      height = 15;
      battery = {
        width = 50;
        heightPercent = 90;
        warnPercent = 50;
        critPercent = 25;
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
      content = lib.pipe config.settings [
        (lib.mapAttrsToList (n: v: "const ${n} = ${builtins.toJSON v};"))
        (builtins.concatStringsSep "\n")
      ];
    };
    config.constructFiles.reload = {
      relPath = "bin/quickshell-config-reload";
      content = ''
        #!${pkgs.bash}${pkgs.bash.shellPath}
        ${config.wrapperPaths.placeholder} ipc call top quit
        ${config.wrapperPaths.placeholder}
      '';
      builder = ''
        cp "$1" "$2"
        chmod +x "$2"
      '';
    };
    config.buildCommand.mkCfg = ''
      ${lib.getExe pkgs.lndir} ${./config} ${config.generated.placeholder}
    '';
  };
}
