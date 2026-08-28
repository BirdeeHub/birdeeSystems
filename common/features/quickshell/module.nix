{inputs, ...}:
{
  flake.wrappers.quickshell = { config, lib, wlib, pkgs, ... }: {
    imports = [ wlib.wrapperModules.quickshell ];
    options.i3status = lib.mkOption {
      type = wlib.types.subWrapperModule {
        imports = [ inputs.self.wrapperModules.i3status ];
        config.pkgs = pkgs;
      };
    };
    config.configFile = ''
      //@ pragma UseQApplication
      import Quickshell
      I3Bar {
        i3status: "${lib.getExe config.i3status.wrapper}"
        isSway: false
      }
    '';
    config.buildCommand.mkCfg = ''
      ${lib.getExe pkgs.lndir} ${./config} ${config.generated.placeholder}
    '';
  };
}
