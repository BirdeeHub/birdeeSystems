{ mkRecBuilder, pipe, ... }: with builtins; rec {
  compile_lua_dir = {
    name ? "REPLACE_ME",
    LUA_SRC,
    CPATH_DIR ? null,
    lua_interpreter,
    lua_packages ? (_:[]),
    extraLuaPackages ? (_:[]),
    miscNixVals ? {},
    mkDerivation,
    ...
    }: let
    luaFileAction = /*bash*/''
      local file=$1
      local outdir=$2
      shift 2
      echo "$@" "$(basename "$file")"
      if [[ "$file" == *.lua ]]; then
        if [ -e "${lua_interpreter}/bin/luajit" ]; then
          ${lua_interpreter}/bin/luajit -b -d -s "$file" "$outdir/$(basename "$file")" || cp -f "$file" "$outdir"
        else
          ${lua_interpreter}/bin/luac -s -o "$outdir/$(basename "$file")" "$file" || cp -f "$file" "$outdir"
        fi
      else
        cp -f "$file" "$outdir"
      fi
    '';
    env_path = pipe lua_interpreter.LuaPathSearchPaths [ head (split "[?]") head dirOf ];
    env_cpath = pipe lua_interpreter.LuaCPathSearchPaths [ head (split "[?]") head dirOf ];
    mknixluavals = ''echo 'return ${lib.generators.toLua { } miscNixVals}' > $out/${env_path}/NIX_${name}_VALUES.lua'';
    app = mkDerivation (finalAttrs: {
      inherit name;
      src = LUA_SRC;
      dontUnpack = true;
      propagatedBuildInputs = (lua_packages lua_interpreter.pkgs) ++ (extraLuaPackages lua_interpreter.pkgs);
      buildPhase = ''
        runHook preBuild
        ${mkRecBuilder { action = luaFileAction; src = "$src"; outdir = "$out/${env_path}"; }}
        ${mknixluavals}
        ${if CPATH_DIR == null then "" else ''
          mkdir -p $out/${env_cpath}
          cp -r ${CPATH_DIR}/* $out/${env_cpath}
        ''}
        runHook postBuild
      '';
    });
  in lua_interpreter.pkgs.luaLib.toLuaModule app;

}
