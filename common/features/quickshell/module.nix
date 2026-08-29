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
      Scope {
        My3Bar {
          i3status: "${lib.getExe config.i3status.wrapper}"
          isSway: false
        }
        NotifyDeez {}
      }
    '';
    config.buildCommand.mkCfg = ''
      ${lib.getExe pkgs.lndir} ${./config} ${config.generated.placeholder}
    '';
  };
}
