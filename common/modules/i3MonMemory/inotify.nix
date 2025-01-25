{ pkgs, ... }@args: let

  i3luaMon = {
    appname
    , userJsonCache ? null
    , xrandrOthersSH
    , xrandrPrimarySH
    , triggerFile
    , nixToLua
    , pkgs
    , lua5_2
    , lib
    , stdenv
    , writeShellScript
    , ...
  }: let
    luaEnv = lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
    luaProgPath = with pkgs; [ i3 xorg.xrandr gawk ];
    toPass = {
        json_cache = userJsonCache;
        always_run = xrandrPrimarySH;
        newmon = xrandrOthersSH;
    };
    luaProg = stdenv.mkDerivation {
      name = appname;
      src = ./${appname}.lua;
      phases = [ "buildPhase" ];
      buildPhase = let
        nixinfo = "package.preload[ [[nixinfo]] ] = function() return ${nixToLua.uglyLua toPass} end";
      in /*bash*/''
        TEMPFILE=$(mktemp) TEMPOUTFILE=$(mktemp)
        cleanup() {
          rm -f "$TEMPFILE" "$TEMPOUTFILE" || true
        }
        trap cleanup EXIT
        echo ${lib.escapeShellArg nixinfo} > "$TEMPFILE";
        cat $src >> "$TEMPFILE"
        ${luaEnv}/bin/luac -o "$TEMPOUTFILE" "$TEMPFILE"
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

in pkgs.callPackage i3luaMon (args // { appname = "i3luaMon"; })
