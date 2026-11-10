{
  lua,
  shelua ? null, # needed for now because shelua is not in nixpkgs
  std_deps ? (lp: [ shelua lp.inspect lp.luv lp.cjson ]) lua.pkgs,
}: derivation (let
  topath = list: let
    l = map (v: v.passthru.luaModule.pkgs.getLuaPath v) list;
  in builtins.concatStringsSep ";" l + (if l != [] then ";" else "");
  toCpath = list: let
    l = map (v: v.passthru.luaModule.pkgs.getLuaCPath v) list;
  in builtins.concatStringsSep ";" l + (if l != [] then ";" else "");
in {
  name = "lua-builder";
  builder = lua.interpreter;
  inherit (lua) system;
  args = [
    "-e"
    ''
      local out = ${builtins.toJSON (placeholder "out")}
      local f = assert(io.open(out, "w"))
      f:write(${builtins.toJSON ''
      #!${builtins.toJSON lua.interpreter}
      package.path = ${builtins.toJSON (topath std_deps)} .. package.path
      package.cpath = ${builtins.toJSON (toCpath std_deps)} .. package.cpath
      assert(pcall(dofile(${builtins.toJSON ./nix.lua}), ${builtins.toJSON ./.}))''})
      f:close()
    ''
  ];
})
