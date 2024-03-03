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
  firefox = homeOnly ./firefox/homeFox.nix;
  thunar = homeOnly ./thunar;
  ranger = homeOnly ./ranger;
  birdeeVim = {
    module= if homeModule
      then birdeeVim.homeModule
      else birdeeVim.nixosModules.default;
    packages = birdeeVim.packages;
    utils = birdeeVim.utils;
    overlays = birdeeVim.overlays;
    devShell = birdeeVim.devShell;
    customPackager = birdeeVim.customPackager;
    dependencyOverlays = birdeeVim.dependencyOverlays;
    categoryDefinitions = birdeeVim.categoryDefinitions;
    packageDefinitions = birdeeVim.packageDefinitions;
  };
  i3 = import ./i3 homeModule;
  i3MonMemory = import ./i3MonMemory homeModule;
  lightdm = systemOnly ./lightdm;
  term = {
    alacritty = import ./term/alacritty homeModule;
    tmux = import ./term/tmux homeModule;
  };
  shell = import ./term/shell (args // conditions);
  util = import ./util {};
}
