{ inputs, birdeeutils }: let
  mods = builtins.listToAttrs (map (n: { name = n; value = ./${n}; }) (builtins.attrNames (inputs.nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.))));
  modules = mods // {
    tmux = import mods.tmux inputs;
    wezterm = import mods.wezterm inputs;
    luakit = import mods.luakit { inherit birdeeutils inputs; };
    xplr = import mods.xplr { inherit birdeeutils inputs; };
  };
in {
  modules = modules;
  wrapperModules = builtins.mapAttrs (n: v: (inputs.wrappers.lib.evalModule v).config) modules;
}
