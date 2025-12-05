{ inputs, birdeeutils, ... }@args: let
  mods = builtins.listToAttrs (map (n: { name = n; value = ./${n}; }) (builtins.attrNames (inputs.nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.))));
  applyfirst = {
    tmux = true;
    wezterm = true;
    luakit = true;
    xplr = true;
    nushell = true;
  };
  modules = builtins.mapAttrs (n: v: if applyfirst.${n} or null != null then import v args else v) mods;
in {
  modules = modules;
  wrapperModules = builtins.mapAttrs (n: v: (inputs.wrappers.lib.evalModule v).config) modules;
}
