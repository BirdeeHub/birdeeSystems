{ pkgs, nixToLua, ... }@args: let
  luaMon = {
    pkgs
    , lib
    , stdenv
    , writeShellScript

    , appname
    , userJsonCache ? null
    , xrandrOthersSH
    , xrandrPrimarySH
    , triggerFile
    , lua ? pkgs.lua5_2
    , luaProgPath ? (with pkgs; [ i3 xrandr gawk ])
    , extraLuaPackages ? (lpkgs: with lpkgs; [ luafilesystem cjson ])
    , toPass ? {
      json_cache = userJsonCache;
      always_run = xrandrPrimarySH;
      newmon = xrandrOthersSH;
    }
    , ...
  }: let
    luaProg = stdenv.mkDerivation {
      name = appname;
      src = ./${appname}.lua;
      phases = [ "buildPhase" ];
      buildPhase = let
        luaEnv = lua.withPackages extraLuaPackages;
        nixinfo = "package.preload[ [[nixinfo]] ] = function() return ${nixToLua.uglyLua toPass} end";
      in /*bash*/''
        TEMPFILE=$(mktemp) TEMPOUTFILE=$(mktemp)
        cleanup() {
          rm -f "$TEMPFILE" "$TEMPOUTFILE" || true
        }
        trap cleanup EXIT
        echo ${lib.escapeShellArg nixinfo} > "$TEMPFILE";
        cat $src >> "$TEMPFILE"
        if [ -e "${luaEnv}/bin/luajit" ]; then
          ${luaEnv}/bin/luajit -b -d -s "$TEMPFILE" "$TEMPOUTFILE"
        else
          ${luaEnv}/bin/luac -s -o "$TEMPOUTFILE" "$TEMPFILE"
        fi
        echo '#!${luaEnv.interpreter}' > $out
        cat "$TEMPOUTFILE" >> $out
        cleanup
        chmod +x $out
      '';
    };
    i3notifyMon = writeShellScript "runi3xrandrMemory.sh" ''
      PATH="${lib.makeBinPath (with pkgs; [ bash coreutils inotify-tools ])}"
      mkdir -p "$(dirname ${triggerFile})"
      inotifywait -e close_write -m "$(dirname ${triggerFile})" |
      while read -r directory events filename; do
        if [ "$filename" == "$(basename ${triggerFile})" ]; then
          bash -c 'PATH=${lib.makeBinPath luaProgPath} ${luaProg}'
        fi
      done
    '';
  in i3notifyMon;
in pkgs.callPackage luaMon (args // { appname = "i3luaMon"; })
