{homeModule ? false, inputs, pkgs, ... }@args: let
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
    overlays = birdeeVim.overlays;
    devShell = birdeeVim.devShell;
    customPackager = birdeeVim.customPackager;
    dependencyOverlays = birdeeVim.dependencyOverlays;
    categoryDefinitions = birdeeVim.categoryDefinitions;
    packageDefinitions = birdeeVim.packageDefinitions;
  };
  i3 = systemOnly ./i3/system;
  lightdm = systemOnly ./lightdm;
  term = {
    alacritty = import ./term/alacritty homeModule;
    tmux = homeOnly ./term/tmux;
  };
  shell = import ./term/shell args;
  overlays = ./overlays;
}
