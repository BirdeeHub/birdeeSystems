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
    runHook preBuild
    builder_file_action() {
      ${action}
    }
    dirloop() {
      local dir=$1
      local outdir=$2
      local action=$3
      local file=""
      mkdir -p "$outdir"
      for file in "$dir"/*; do
        if [ -d "$file" ]; then
          dirloop "$file" "$outdir/$(basename "$file")" $action
        else
          $action "$file" "$outdir"
        fi
      done
    }
    dirloop ${src} ${outdir} builder_file_action
    runHook postBuild
  '';

  compile_lua_dir = { drvname ? "REPLACE_ME", source, luaEnv, src ? "$src", outdir ? "$out", mkDerivation, ... }: let
    luaFileAction = /*bash*/''
      local file=$1
      local outdir=$2
      if [[ $file == *.lua ]]; then
        if [ -e "${luaEnv}/bin/luajit" ]; then
          ${luaEnv}/bin/luajit -b "$file" "$outdir/$(basename "$file")" || cp -f "$file" "$outdir"
        else
          ${luaEnv}/bin/luac -o "$outdir/$(basename "$file")" "$file" || cp -f "$file" "$outdir"
        fi
      else
        cp -f "$file" "$outdir"
      fi
    '';
    app = mkDerivation {
      name = drvname;
      src = source;
      dontUnpack = true;
      buildPhase = mkRecBuilder { action = luaFileAction; inherit src outdir; };
    };
  in app;

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      lib
      , bash
      , stdenv
      , luajit
      # args below:
      , source
      , appname ? "REPLACE_ME"
      , luaEnv ? luajit
      , procPath ? []
      , libPath ? []
      , extra_launcher_commands ? ""
      , args ? []
      , ...
    }: let
      outdir = "$out/lua/${appname}";
      app_prime = compile_lua_dir {
        drvname = appname;
        inherit outdir source luaEnv;
        inherit (stdenv) mkDerivation;
      };
      in app_prime.overrideAttrs {
        installPhase = let
          luapath = luaEnv.pkgs.luaLib.genLuaPathAbsStr luaEnv;
          luacpath = luaEnv.pkgs.luaLib.genLuaCPathAbsStr luaEnv;
        in /*bash*/ ''
          runHook preInstall
          cat > $out/bin/${appname} <<EOFTAG
          #!${bash}/bin/bash
          export PATH=${lib.makeBinPath procPath}
          export LD_LIBRARY_PATH=${lib.makeLibraryPath libPath}
          export LUA_PATH="${outdir}/?.lua;${outdir}/?/init.lua;${luapath}"
          export LUA_CPATH="${outdir}/?.lua;${outdir}/?/init.lua;${luacpath}"
          ${extra_launcher_commands}
          if [ -e "${luaEnv}/bin/luajit" ]; then
            exec ${luaEnv}/bin/luajit ${outdir}/init.lua ${concatStringsSep " " (map (v: ''"${v}"'') args)} "$@"
          else
            exec ${luaEnv}/bin/lua ${outdir}/init.lua ${concatStringsSep " " (map (v: ''"${v}"'') args)} "$@"
          fi
          EOFTAG
          chmod +x $out/bin/${appname}
          runHook postInstall
        '';
      };
  in callPackage mkLuaAppWcallPackage arguments;

}
