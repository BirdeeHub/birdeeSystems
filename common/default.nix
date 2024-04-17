{ inputs, pkgs, ... }@args: { homeModule ? false, ... }@conditions: let
  birdeeVim = import ./birdeevim { inherit inputs; };
  homeOnly = path:
    (if homeModule
      then path
      else builtins.throw "no system module with that name"
    );
  systemOnly = path:
    (if homeModule
      then builtins.throw "no home-manager module with that name"
      else path
    );
in {
  LD = systemOnly ./LD;
  firefox = homeOnly ./firefox/homeFox.nix;
  thunar = homeOnly ./thunar;
  ranger = import ./ranger homeModule;
  birdeeVim = {
    module= if homeModule
      then birdeeVim.homeModule
      else birdeeVim.nixosModules.default;
    inherit (birdeeVim) packages utils overlays
      devShell customPackager dependencyOverlays
      categoryDefinitions packageDefinitions;
  };
  i3 = import ./i3 homeModule;
  i3MonMemory = import ./i3MonMemory homeModule;
  lightdm = systemOnly ./lightdm;
  term = {
    alacritty = import ./term/alacritty homeModule;
    tmux = import ./term/tmux homeModule;
  };
  shell = import ./term/shell (args // conditions);
  util = import ./util;
}
