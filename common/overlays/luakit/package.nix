{
  lib,
  inputs,
  luakit,
  stdenv,
  luajit,
  makeBinaryWrapper,
  ...
}: stdenv.mkDerivation (final: {
  name = "luakitkat";
  src = builtins.path { path = ./.; };
  nativeBuildInputs = [ makeBinaryWrapper ];
  passthru = {
    luaEnv = luajit.withPackages (lp: []);
    wrapperArgs = [];
    outDir = "${placeholder "out"}";
  };
  passAsFile = [ "nixInfo" ];
  nixInfo = "
    package.preload.nixInfo = function(...) return ${inputs.nixToLua.uglyLua final.passthru} end
    require('birdee')
  ";
  buildPhase = ''
    mkdir -p $out/lua
    ln -s $src/* $out/lua
    { [ -e "$nixInfoPath" ] && cat "$nixInfoPath" || echo "$nixInfo"; } > ${lib.escapeShellArg "${placeholder "out"}/rc.lua"}
    makeWrapper ${luakit}/bin/luakit $out/bin/luakit --inherit-argv0 \
    ${lib.escapeShellArgs ([
      "--add-flag" "-c" "--add-flag" "${placeholder "out"}/rc.lua"
      "--prefix" "LUA_PATH" ";" (luajit.pkgs.luaLib.genLuaPathAbsStr final.passthru.luaEnv)
      "--prefix" "LUA_CPATH" ";" (luajit.pkgs.luaLib.genLuaCPathAbsStr final.passthru.luaEnv)
      "--prefix" "LUA_PATH" ";" "${placeholder "out"}/lua/?.lua;${placeholder "out"}/lua/?/init.lua"
      "--prefix" "LUA_CPATH" ";" "${placeholder "out"}/lua/?.so"
    ] ++ final.passthru.wrapperArgs)}
  '';
})
