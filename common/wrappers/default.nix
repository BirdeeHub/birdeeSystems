{ inputs, util, ... }@args: let
  applyfirst = {
    tmux = true;
    wezterm = true;
    luakit = true;
    xplr = true;
    nushell = true;
  };
  modules = util.pipe (builtins.readDir ./.) [
    (util.filterAttrs (n: v: v == "directory"))
    builtins.attrNames
    (map (n: { name = n; value = ./${n}; }))
    builtins.listToAttrs
    (builtins.mapAttrs (n: v: if applyfirst.${n} or null != null then import v args else v))
  ];
in {
  modules = modules;
  wrapperModules = builtins.mapAttrs (n: v: (inputs.wrappers.lib.evalModule v).config) modules;
}
