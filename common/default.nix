{ inputs, ... }@args: { homeModule ? false, ... }@conditions: let
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
  birdeeVim = import ./birdeevim { inherit inputs; };
  i3 = import ./i3 homeModule;
  i3MonMemory = import ./i3MonMemory homeModule;
  lightdm = systemOnly ./lightdm;
  term = {
    alacritty = import ./term/alacritty homeModule;
    tmux = import ./term/tmux homeModule;
  };
  shell = import ./term/shell homeModule;
  util = import ./util;
  ollama = systemOnly (import ./ollama homeModule);
  # ollama = import ./ollama homeModule;
}
