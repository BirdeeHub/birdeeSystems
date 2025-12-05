{ inputs, birdeeutils, ... }@args: let
  mods = builtins.listToAttrs (map (n: { name = n; value = ./${n}; }) (builtins.attrNames (inputs.nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.))));
  modules = mods // {
    tmux = import mods.tmux args;
    wezterm = import mods.wezterm args;
    luakit = import mods.luakit args;
    xplr = import mods.xplr args;
    nushell = import mods.nushell args;
  };
in {
  modules = modules;
  wrapperModules = builtins.mapAttrs (n: v: (inputs.wrappers.lib.evalModule v).config) modules;
}
