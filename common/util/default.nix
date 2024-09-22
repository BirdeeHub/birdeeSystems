inputs: with builtins; rec {

  linkFarmPair =
    name:
    path:
    { inherit name path; };
  
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

}
