{ shellPkg, APPNAME, mkShell, ... }: let
# dev shells should not contain the final program.
# They should have the environment
# needed to BUILD (and run) the final program.
  DEVSHELL = mkShell {
    packages = [];
    inputsFrom = [];
    DEVSHELL = 0;
    APPNAME = APPNAME;
    shellHook = ''
      exec ${shellPkg}
    '';
  };
in
DEVSHELL
