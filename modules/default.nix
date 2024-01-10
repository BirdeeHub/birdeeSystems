{homeModule ? false, ... }: {
  firefox = if homeModule then ./firefox/homeFox.nix else null;
  hardwares = {
    aSUSrog = if homeModule then null else ./hardwares/aSUSrog.nix;
    nvidiaIntelgrated = if homeModule then null else ./hardwares/nvdintGraphics.nix;
  };
  i3 = if homeModule then null else ./i3;
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
