{ mkRecBuilder, inputs, pipe, ... }: with builtins; rec {
  compile_lua_dir = {
    name ? "REPLACE_ME",
    LUA_SRC,
    CPATH_DIR ? null,
    lua_interpreter,
    lua_packages ? (_:[]),
    extraLuaPackages ? (_:[]),
    miscNixVals ? {},
    toLua ? null,
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
          ${lua_interpreter}/bin/luajit -b "$file" -d "$outdir/$(basename "$file")" || cp -f "$file" "$outdir"
        else
          ${lua_interpreter}/bin/luac -o "$outdir/$(basename "$file")" "$file" || cp -f "$file" "$outdir"
        fi
      else
        cp -f "$file" "$outdir"
      fi
    '';
    env_path = pipe lua_interpreter.LuaPathSearchPaths [ head (split "[\/][?]") head ];
    env_cpath = pipe lua_interpreter.LuaCPathSearchPaths [ head (split "[\/][?]") head ];
    nixluavals = if isFunction toLua then toLua miscNixVals else "";
    mknixluavals = ''echo 'return ${nixluavals}' > $out/${env_path}/NIX_${name}_VALUES.lua'';
    app = mkDerivation (finalAttrs: {
      inherit name;
      src = LUA_SRC;
      dontUnpack = true;
      propagatedBuildInputs = (lua_packages lua_interpreter.pkgs) ++ (extraLuaPackages lua_interpreter.pkgs);
      buildPhase = ''
        runHook preBuild
        ${mkRecBuilder { action = luaFileAction; src = "$src"; outdir = "$out/${env_path}"; }}
        ${if isFunction toLua then mknixluavals else ""}
        ${if CPATH_DIR == null then "" else ''
          mkdir -p $out/${env_cpath}
          cp -r ${CPATH_DIR}/* $out/${env_cpath}
        ''}
        runHook postBuild
      '';
    });
  in lua_interpreter.pkgs.luaLib.toLuaModule app;

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      lib
      , stdenv
      , makeWrapper
      , lua5_2
      # args below:
      , LUA_SRC
      , CPATH_DIR ? null
      , lua_interpreter ? lua5_2
      , lua_packages ? (_:[])
      , extraLuaPackages ? (_:[])
      , APPNAME ? "REPLACE_ME"
      , wrapperArgs ? []
      , miscNixVals ? {}
      , toLua ? null
      , ...
    }: let
      compiled = lib.makeOverridable compile_lua_dir {
        name = APPNAME;
        inherit (stdenv) mkDerivation;
        inherit lua_interpreter lua_packages extraLuaPackages LUA_SRC CPATH_DIR miscNixVals toLua;
      };
      app_final = stdenv.mkDerivation (let
        luaEnv = compiled.luaModule.withPackages (_: [ compiled ]);
      in {
        name = APPNAME;
        src = compiled;
        nativeBuildInputs = [ makeWrapper ];
        propagatedBuildInputs = [ compiled ];
        passthru = {
          inherit luaEnv;
          unwrapped = compiled;
        };
        buildPhase = /*bash*/''
          runHook preBuild
          mkdir -p $out/bin
          cat > $out/bin/${APPNAME} <<EOFTAG_LUA
          #!${luaEnv.interpreter}
          require([[${APPNAME}]])
          EOFTAG_LUA
          chmod +x $out/bin/${APPNAME}
          runHook postBuild
        '';
        postFixup = /*bash*/''
          wrapProgram $out/bin/${APPNAME} ${concatStringsSep " " wrapperArgs}
        '';
      });
    in
    lua_interpreter.pkgs.luaLib.toLuaModule app_final;
  in callPackage mkLuaAppWcallPackage (arguments // { toLua = inputs.nixToLua.toLua; });

}
