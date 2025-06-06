{ inputs, homeManager ? false, birdeeutils, ... }: let
  homeOnly = path:
    (if homeManager
      then path
      else builtins.throw "no system module with that name"
    );
  systemOnly = path:
    (if homeManager
      then builtins.throw "no home-manager module with that name"
      else path
    );
  moduleNamespace = "birdeeMods";
  args = { inherit inputs moduleNamespace homeManager birdeeutils; };
in {
  birdeevim = import ./birdeevim args;
  LD = import (systemOnly ./LD) args;
  firefox = import (homeOnly ./firefox) args;
  thunar = import (homeOnly ./thunar) args;
  ranger = import ./ranger args;
  i3 = import ./i3 args;
  i3MonMemory = import ./i3MonMemory args;
  lightdm = import (systemOnly ./lightdm) args;
  alacritty = import ./alacritty args;
  tmux = import ./tmux args;
  shell = import ./shell args;
  aliasNetwork = import (systemOnly ./aliasNetwork) args;
  old_modules_compat = import ./old_modules_compat args;
}
