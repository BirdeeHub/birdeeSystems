{
  lib,
  inputs,
  luakit,
  stdenv,
  luajit,
  makeBinaryWrapper,
  birdeeutils,
  ...
}: stdenv.mkDerivation (final: {
  name = "luakitkat";
  src = builtins.path { path = ./.; };
  nativeBuildInputs = [ makeBinaryWrapper ];
  passthru = {
    luaEnv = luajit.withPackages (lp: [
    ]);
    wrapperArgs = [];
  };
  passAsFile = [ "nixInfo" ];
  nixInfo = /*lua*/ ''
    package.preload.nixInfo = function(...)
      return ${inputs.nixToLua.uglyLua (final.passthru // { outDir = "${placeholder "out"}"; })}
    end
    dofile('${placeholder "out"}/init.lua')
  '';
  buildPhase = ''
    mkdir -p $out
    ln -s $src/*.lua $out || true
    { [ -e "$nixInfoPath" ] && cat "$nixInfoPath" || echo "$nixInfo"; } > ${lib.escapeShellArg "${placeholder "out"}/rc.lua"}
    ${birdeeutils.mkRecBuilder {
      src = "$src/cfg";
      out = "$out/cfg";
      action = /*bash*/''
        [[ "$1" == *.c ]] && {
          $CC -O2 -fPIC -shared -I"${final.passthru.luaEnv}/include" -o "$2/$(basename "$1" .c).so" "$1"
        } || ln -s "$1" "$2"
      '';
    }}
    makeWrapper ${luakit}/bin/luakit $out/bin/luakit --inherit-argv0 \
      ${lib.escapeShellArgs ([
        "--add-flag" "-c" "--add-flag" "${placeholder "out"}/rc.lua"
        "--prefix" "LUA_PATH" ";" (luajit.pkgs.luaLib.genLuaPathAbsStr final.passthru.luaEnv)
        "--prefix" "LUA_CPATH" ";" (luajit.pkgs.luaLib.genLuaCPathAbsStr final.passthru.luaEnv)
        "--prefix" "LUA_PATH" ";" "${placeholder "out"}/cfg/?.lua;${placeholder "out"}/cfg/?/init.lua"
        "--prefix" "LUA_CPATH" ";" "${placeholder "out"}/cfg/?.so"
      ] ++ final.passthru.wrapperArgs)}
  '';
})
