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
  inherit (final.luaInterpreters)
  lua5_1
  lua5_2
  lua5_2_compat
  lua5_3
  lua5_3_compat
  lua5_4
  lua5_4_compat
  lua5_5
  lua5_5_compat
  luajit_2_1
  luajit_2_0
  luajit_openresty;

  lua5 = final.lua5_2_compat;
  lua = final.lua5;
  lua51Packages = prev.lib.recurseIntoAttrs final.lua5_1.pkgs;
  lua52Packages = prev.lib.recurseIntoAttrs final.lua5_2.pkgs;
  lua53Packages = prev.lib.recurseIntoAttrs final.lua5_3.pkgs;
  lua54Packages = prev.lib.recurseIntoAttrs final.lua5_4.pkgs;
  lua55Packages = prev.lib.recurseIntoAttrs final.lua5_5.pkgs;
  luajitPackages = prev.lib.recurseIntoAttrs final.luajit.pkgs;
  luaPackages = final.lua52Packages;
  luajit = final.luajit_2_1;
  emiluaPlugins = prev.lib.recurseIntoAttrs (final.callPackage ./emilua-plugins.nix {} (final.callPackage ../development/interpreters/emilua {}));
  inherit (final.emiluaPlugins) emilua;
  luarocks = final.luaPackages.luarocks;
  luarocks-nix = final.luaPackages.luarocks-nix;
  toluapp = final.callPackage ../development/tools/toluapp { lua = final.lua5_1; };
  ${if prev.lib.isFunction vimPlugins then "vimPlugins" else null} = prev.vimPlugins // vimPlugins final prev;
}
