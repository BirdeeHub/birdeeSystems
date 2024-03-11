with builtins; rec {

  mkScriptAliases = packageSet: concatStringsSep "\n" (mapAttrs (name: value: ''
      ${name}() {
        ${value}/bin/${name} "$@"
      }
  '') packageSet);

  mkRecBuilder = { src ? "$src", outdir ? "$out", action ? "cp $1 $2", ... }: /* bash */''
    source $stdenv/setup
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
  '';

  mkLuaApp = arguments: let
    mkLuaAppWcallPackage = {
      pkgs
      , lib
      , writeShellScriptBin
      , writeShellScript
      , writeText
      , stdenv
      # args below:
      , appname
      , procPath
      , luaEnv
      , source
      , extra_launcher_lua ? ""
      , extra_launcher_commands ? ""
      , args ? []
      , to_bin ? true
      , ...
    }: let
      luaFileAction = /*bash*/''
        local file=$1
        local outdir=$2
        if [[ $file == *.lua ]]; then
          ${luaEnv}/bin/luac -o "$outdir/$(basename "$file" .lua).luac" "$file"
        else
          cp "$file" "$outdir"
        fi
      '';
      app = stdenv.mkDerivation {
        name = "${appname}";
        src = source;
        phases = [ "buildPhase" ];
        buildPhase = mkRecBuilder { action = luaFileAction; };
      };
      launcher = let
        main = writeText "main.lua" /* lua */ ''
          package.path = package.path .. [[;${app}/?.luac;${app}/?/init.luac;./?.luac;./?/init.luac]]
          package.cpath = package.cpath .. [[;${app}/?.luac;${app}/?/init.luac;./?.luac;./?/init.luac]]
          ${extra_launcher_lua}
          dofile("${app}/init.luac")
        '';
      in (if to_bin then writeShellScriptBin else writeShellScript) "${appname}" ''
        export PATH=${lib.makeBinPath procPath}
        ${extra_launcher_commands}
        ${luaEnv}/bin/lua ${main} "${concatStringsSep " " (map (v: ''"${v}"'') args)}" "$@"
      '';
    in launcher;
  in arguments.pkgs.callPackage mkLuaAppWcallPackage arguments;

  luaTablePrinter = attrSet: let
    luatableformatter = attrSet: let
      nameandstringmap = mapAttrs (n: value: let
          name = ''[ [[${n}]] ]'';
        in
        if value == true then "${name} = true"
        else if value == false then "${name} = false"
        else if value == null then "${name} = nil"
        else if lib.isDerivation value then "${name} = [[${value}]]"
        else if isList value then "${name} = ${luaListPrinter value}"
        else if isAttrs value then "${name} = ${luaTablePrinter value}"
        else "${name} = [[${toString value}]]"
      ) attrSet;
      resultList = attrValues nameandstringmap;
      resultString = concatStringsSep ", " resultList;
    in
    resultString;
    catset = luatableformatter attrSet;
    LuaTable = "{ " + catset + " }";
  in
  LuaTable;

  luaListPrinter = theList: let
    lualistformatter = theList: let
      stringlist = map (value:
        if value == true then "true"
        else if value == false then "false"
        else if value == null then "nil"
        else if lib.isDerivation value then "[[${value}]]"
        else if isList value then "${luaListPrinter value}"
        else if isAttrs value then "${luaTablePrinter value}"
        else "[[${toString value}]]"
      ) theList;
      resultString = concatStringsSep ", " stringlist;
    in
    resultString;
    catlist = lualistformatter theList;
    LuaList = "{ " + catlist + " }";
  in
  LuaList;
}
