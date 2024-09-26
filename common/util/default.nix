inputs: with builtins; rec {

  linkFarmPair =
    name:
    path:
    { inherit name path; };

  eachSystem = with builtins; systems: f:
    let
      # Merge together the outputs for all systems.
      op = attrs: system:
        let
          ret = f system;
          op = attrs: key: attrs //
              {
                ${key} = (attrs.${key} or { })
                  // { ${system} = ret.${key}; };
              }
          ;
        in
        foldl' op attrs (attrNames ret);
    in
    foldl' op { }
      (systems
        ++ # add the current system if --impure is used
          (if builtins ? currentSystem then
             if elem currentSystem systems
             then []
             else [ currentSystem ]
          else []));

  mkRecBuilder = { src ? "$src", outdir ? "$out", action ? "cp $1 $2", ... }: /* bash */''
    builder_file_action() {
      ${action}
    }
    dirloop() {
      local dir=$1
      local outdir=$2
      local action=$3
      shift 3
      local dirnames=("$@")
      local file=""
      mkdir -p "$outdir"
      for file in "$dir"/*; do
        if [ -d "$file" ]; then
          dirloop "$file" "$outdir/$(basename "$file")" $action "''${dirnames[@]}" "$(basename "$file")"
        else
          $action "$file" "$outdir" "''${dirnames[@]}"
        fi
      done
    }
    dirloop ${src} ${outdir} builder_file_action
  '';

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
          ${lua_interpreter}/bin/luajit -b "$file" -d "$outdir/$(basename "$file")" || cp -f "$file" "$outdir"
        else
          ${lua_interpreter}/bin/luac -o "$outdir/$(basename "$file")" "$file" || cp -f "$file" "$outdir"
        fi
      else
        cp -f "$file" "$outdir"
      fi
    '';
    app = mkDerivation (finalAttrs: (let
      env_path = builtins.head (builtins.split "[\/][?]" (builtins.head lua_interpreter.LuaPathSearchPaths));
      env_cpath = builtins.head (builtins.split "[\/][?]" (builtins.head lua_interpreter.LuaCPathSearchPaths));
      nixluavals = inputs.nixToLua.prettyNoModify miscNixVals;
    in {
      inherit name;
      src = LUA_SRC;
      dontUnpack = true;
      propagatedBuildInputs = (lua_packages lua_interpreter.pkgs) ++ (extraLuaPackages lua_interpreter.pkgs);
      buildPhase = ''
        runHook preBuild
        ${mkRecBuilder { action = luaFileAction; src = "$src"; outdir = "$out/${env_path}"; }}
        echo 'return ${nixluavals}' > $out/${env_path}/NIX_${name}_VALUES
        ${if CPATH_DIR == null then "" else ''
          mkdir -p $out/${env_cpath}
          cp -r ${CPATH_DIR}/* $out/${env_cpath}
        ''}
        runHook postBuild
      '';
    }));
  in lua_interpreter.pkgs.luaLib.toLuaModule app;

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      stdenv
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
      , ...
    }: let
      compiled = compile_lua_dir {
        name = APPNAME;
        inherit (stdenv) mkDerivation;
        inherit lua_interpreter lua_packages extraLuaPackages LUA_SRC CPATH_DIR miscNixVals;
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
        };
        buildPhase = let
          binarypath = if builtins.pathExists "${luaEnv}/bin/luajit" then "${luaEnv}/bin/luajit" else "${luaEnv}/bin/lua";
        in /*bash*/''
          runHook preBuild
          mkdir -p $out/bin
          cat > $out/bin/${APPNAME} <<EOFTAG_LUA
          #!${binarypath}
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
  in callPackage mkLuaAppWcallPackage arguments;

}
