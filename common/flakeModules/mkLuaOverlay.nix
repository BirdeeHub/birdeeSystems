{
  # takes a lua packageOverrides overlay
  packageOverrides,
  # takes an overlay but which the returned values are placed into vimPlugins instead
  vimPlugins ? null,
  # lua versions control
  versions ? [],
  controlType ? "exclude",
  ...
}:
  assert builtins.isList versions || throw "lua versions must be a list of strings containing `lua.luaAttr` names corresponding to `pkgs.luaInterpreters`!";
  assert controlType == "build" || controlType == "exclude" || throw ''controlType must be "build" or "exclude"'';
final: prev: {
  luaInterpreters = prev.luaInterpreters // prev.lib.pipe (
    if controlType == "build" then
      prev.lib.intersectLists versions (builtins.attrNames prev.luaInterpreters)
    else
      builtins.filter (x: !builtins.elem x versions) (builtins.attrNames prev.luaInterpreters)
  ) [
    (map (v: prev.lib.nameValuePair v packageOverrides))
    builtins.listToAttrs
    (builtins.mapAttrs (
      n: new: prev.luaInterpreters.${n}.override (old: {
        packageOverrides = prev.lib.composeExtensions (old.packageOverrides or (_: _: {})) new;
      })
    ))
  ];
  ${if prev.lib.isFunction vimPlugins then "vimPlugins" else null} = prev.vimPlugins // vimPlugins final prev;
}
