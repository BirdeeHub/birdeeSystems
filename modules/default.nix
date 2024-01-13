{homeModule ? false, inputs, pkgs, ... }: let
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
  hardwares = {
    aSUSrog = systemOnly ./hardwares/aSUSrog.nix;
    nvidiaIntelgrated = systemOnly ./hardwares/nvdintGraphics.nix;
  };
  birdeeVim = {
    module= if homeModule
      then birdeeVim.homeModule.${pkgs.system}
      else birdeeVim.nixosModules.${pkgs.system}.default;
    packages = birdeeVim.packages;
    overlays = birdeeVim.overlays;
    devShell = birdeeVim.devShell;
    customPackager = birdeeVim.customPackager;
    dependencyOverlays = birdeeVim.dependencyOverlays;
    categoryDefinitions = birdeeVim.categoryDefinitions;
    packageDefinitions = birdeeVim.packageDefinitions;
    utils = inputs.nixCats.utils;
  };
  i3 = systemOnly ./i3;
  term = {
    alacritty = if homeModule
      then ./term/alacritty/home-alacritty.nix
      else ./term/alacritty/system-alacritty.nix;
  };
  shell = {
    bash = if homeModule then ./shell/home/bash.nix else ./shell/nixOS/bash.nix;
    zsh = if homeModule then ./shell/home/zsh.nix else ./shell/nixOS/zsh.nix;
    fish = if homeModule then ./shell/home/fish.nix else ./shell/nixOS/fish.nix;
  };
}
