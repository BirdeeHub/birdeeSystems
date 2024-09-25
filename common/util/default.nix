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

  compile_lua_dir = { name ? "REPLACE_ME", lua_interpreter, src, outdir ? "$out", mkDerivation, ... }: let
    luaFileAction = /*bash*/''
      local file=$1
      local outdir=$2
      shift 2
      echo "$@" "$(basename "$file")"
      if [[ "$file" == *.lua ]]; then
        if [ -e "${lua_interpreter}/bin/luajit" ]; then
          ${lua_interpreter}/bin/luajit -b "$file" "$outdir/$(basename "$file")" || cp -f "$file" "$outdir"
        else
          ${lua_interpreter}/bin/luac -o "$outdir/$(basename "$file")" "$file" || cp -f "$file" "$outdir"
        fi
      else
        cp -f "$file" "$outdir"
      fi
    '';
    app = mkDerivation {
      inherit src name;
      dontUnpack = true;
      buildPhase = ''
        runHook preBuild
        ${mkRecBuilder { action = luaFileAction; src = "$src"; inherit outdir; }}
        runHook postBuild
      '';
    };
  in lua_interpreter.pkgs.luaLib.toLuaModule app;

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      stdenv
      , makeWrapper
      , lua5_2
      # args below:
      , APP_SRC
      , lua_interpreter ? lua5_2
      , lua_packages ? (_:[])
      , extraLuaPackages ? (_:[])
      , APPNAME ? "REPLACE_ME"
      , wrapperArgs ? []
      , ...
    }: let
      compiled = compile_lua_dir (let
        env_path = builtins.head (builtins.split "[\/][?]" (builtins.head lua_interpreter.LuaPathSearchPaths));
      in {
        name = "${APPNAME}-compiled";
        src = APP_SRC;
        outdir = "$out/${env_path}";
        inherit lua_interpreter;
        inherit (stdenv) mkDerivation;
      });
      app_final = stdenv.mkDerivation (finalAttrs: {
        name = APPNAME;
        src = compiled;
        nativeBuildInputs = [ makeWrapper ];
        propagatedBuildInputs = lua_packages lua_interpreter.pkgs ++ [ compiled ];
        passthru = let
          withPackages = lpf: lua_interpreter.buildEnv.override (prev: {
            extraLibs = finalAttrs.propagatedBuildInputs ++ (lpf lua_interpreter.pkgs);
          });
        in {
          lua = {
            inherit withPackages;
            env = withPackages extraLuaPackages;
          };
          luaModules = lua_interpreter;
          requiredLuaModules = finalAttrs.propagatedBuildInputs ++ (extraLuaPackages lua_interpreter.pkgs);
        };
        buildPhase = let
          binarypath = if builtins.pathExists "${finalAttrs.passthru.lua.env}/bin/luajit" then "${finalAttrs.passthru.lua.env}/bin/luajit" else "${finalAttrs.passthru.lua.env}/bin/lua";
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
    app_final;
  in callPackage mkLuaAppWcallPackage arguments;

}
