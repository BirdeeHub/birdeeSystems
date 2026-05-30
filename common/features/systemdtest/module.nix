{ ...}: {
  flake.wrappers.systemdtest = { config, pkgs, wlib, lib, ...}: let
    num = 18;
    bleh = pkgs.writeShellScriptBin "bleh" ''
      echo "test user systemd action $(${pkgs.coreutils}/bin/date)" "$@" > /home/birdee/SYSTEMDTESTSUCCESSFUL
    '';
  in {
    imports = [ wlib.modules.default wlib.modules.systemd ];
    package = bleh;
    addFlag = [ "number ${toString num}" ];
    systemd.user.service.${"birdeetest" + toString num}.Service.ExecStart = config.wrapperPaths.placeholder;
    systemd.user.timer.${"birdeetest" + toString num} = {
      Timer = {
        Persistent = true;
        OnCalendar = [ "minutely" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
  flake.modules.nixos.systemdtest-mod = {...}: {
    wrappers.systemdtest.enable = false;
  };
  flake.modules.homeManager.systemdtest-mod = {...}: {
    wrappers.systemdtest.enable = false;
  };
}
