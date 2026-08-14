{ pkgs, ... }@args: pkgs.callPackage ({
  pkgs
  , lib
  , stdenv
  , lua ? pkgs.lua5_2
  , extraLuaPackages ? (lpkgs: with lpkgs; [ luafilesystem cjson osenv shelua inspect ])
  , toPass ? {}
  , ...
}: stdenv.mkDerivation {
  name = "i3Monager";
  src = ./i3Monager.lua;
  phases = [ "buildPhase" ];
  buildPhase = let
    luaEnv = lua.withPackages extraLuaPackages;
    filewatcher = stdenv.mkDerivation {
      name = "filewatcher";
      src = ./filewatcher.c;
      phases = [ "buildPhase" ];
      env.LUA_INC = "${luaEnv}/include";
      buildPhase = ''
        $CC -x c -O2 -fPIC -shared -I$LUA_INC -o $out $src
      '';
    };
    addwatcher = "package.preload[ [[filewatcher]] ] = assert(package.loadlib(${builtins.toJSON filewatcher}, [[luaopen_filewatcher]]))";
    nixinfo = "package.preload[ [[nixinfo]] ] = function() return ${lib.generators.toLua { } (toPass // { extra_path = lib.makeBinPath toPass.extra_path; })} end";
  in /*bash*/''
    TEMPFILE=$(mktemp) TEMPOUTFILE=$(mktemp)
    cleanup() {
      rm -f "$TEMPFILE" "$TEMPOUTFILE" || true
    }
    trap cleanup EXIT
    echo ${lib.escapeShellArg addwatcher} > "$TEMPFILE";
    echo ${lib.escapeShellArg nixinfo} >> "$TEMPFILE";
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
}) args
