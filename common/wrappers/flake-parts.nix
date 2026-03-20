{ inputs, util, ... }@args:
{
  flake.wrappers = util.mapModDirs args {
    tmux = true;
    somewm = true;
    alacritty = true;
    zsh = true;
    wezterm = true;
    ranger = true;
    luakit = true;
    xplr = true;
    nushell = true;
  } ./.;
}
