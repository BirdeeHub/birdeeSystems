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

  compile_lua_dir = { drvname ? "REPLACE_ME", source, luaEnv, mkDerivation, ... }: let
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
      buildPhase = mkRecBuilder { action = luaFileAction; };
    };
  in app;

  mkLuaApp = callPackage: arguments: let
    mkLuaAppWcallPackage = {
      lib
      , writeShellScriptBin
      , writeShellScript
      , writeText
      , stdenv
      , luajit
      # args below:
      , source
      , luaEnv ? luajit
      , appname ? "REPLACE_ME"
      , procPath ? []
      , extra_launcher_lua ? ""
      , extra_launcher_commands ? ""
      , args ? []
      , to_bin ? true
      , ...
    }: let
      app = compile_lua_dir { drvname = appname; inherit source luaEnv; inherit (stdenv) mkDerivation; };
      launcher = let
        main = writeText "main.lua" /* lua */ ''
          package.path = package.path .. [[;${app}/?.lua;${app}/?/init.lua]]
          package.cpath = package.cpath .. [[;${app}/?.lua;${app}/?/init.lua]]
          ${extra_launcher_lua}
          dofile("${app}/init.lua")
        '';
      in (if to_bin then writeShellScriptBin else writeShellScript) appname ''
        export PATH=${lib.makeBinPath procPath}
        ${extra_launcher_commands}
        if [ -e "${luaEnv}/bin/luajit" ]; then
          ${luaEnv}/bin/luajit ${main} ${concatStringsSep " " (map (v: ''"${v}"'') args)} "$@"
        else
          ${luaEnv}/bin/lua ${main} ${concatStringsSep " " (map (v: ''"${v}"'') args)} "$@"
        fi
      '';
    in launcher;
  in callPackage mkLuaAppWcallPackage arguments;

}
