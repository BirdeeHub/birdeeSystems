{ inputs, util, ... }@args:
let
  applyfirst = {
    tmux = true;
    wezterm = true;
    luakit = true;
    xplr = true;
    nushell = true;
  };
in
{
  flake.wrappers = util.pipe (builtins.readDir ./.) [
    (util.filterAttrs (n: v: v == "directory"))
    builtins.attrNames
    (map (n: {
      name = n;
      value = ./${n};
    }))
    builtins.listToAttrs
    (builtins.mapAttrs (n: v: if applyfirst.${n} or null != null then inputs.nixpkgs.lib.modules.importApply v args else v))
  ];
}
