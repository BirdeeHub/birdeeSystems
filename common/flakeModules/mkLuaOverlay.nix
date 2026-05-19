{
  # takes a lua packageOverrides overlay or a list of them
  packageOverrides,
  # takes the same types, but it is a top level overlay, and null to disable
  vimPlugins ? null,
  # lua versions control
  versions ? [],
  controlType ? "exclude",
  ...
}:
  assert builtins.isList versions || throw "lua versions must be a list of strings containing `lua.luaAttr` names corresponding to `pkgs.luaInterpreters`!";
  assert controlType == "build" || controlType == "exclude" || throw ''controlType must be "build" or "exclude"'';
final: prev: let
  final-versions = if controlType == "build" then
    prev.lib.intersectLists versions (builtins.attrNames prev.luaInterpreters)
  else
    prev.lib.pipe prev.luaInterpreters [
      builtins.attrNames
      (builtins.filter (x: !builtins.elem x versions))
    ];
in {
  # https://github.com/NixOS/nixpkgs/blob/dd950ec2fda73b76273d3812a1a5cf35c77b4b69/pkgs/top-level/all-packages.nix#L4866-L4907
  luaInterpreters = prev.luaInterpreters // prev.lib.pipe final-versions [
    (map (v: prev.lib.nameValuePair v packageOverrides))
    builtins.listToAttrs
    (builtins.mapAttrs (
      n: new: prev.luaInterpreters.${n}.override (old: {
        packageOverrides = prev.lib.composeExtensions (old.packageOverrides or (_: _: {})) new;
      })
    ))
  ];
}
