{
  lib,
  inputs,
  luakit,
  stdenv,
  luajit,
  makeBinaryWrapper,
  writeText,
  ...
}: stdenv.mkDerivation (final: {
  name = "luakitkat";
  src = builtins.path { path = ./.; };
  nativeBuildInputs = [ makeBinaryWrapper ];
  passthru = {
    luaEnv = luajit.withPackages (lp: []);
    wrapperArgs = [];
  };
  buildPhase = ''
    mkdir -p $out/lua
    ln -s $src/* $out/lua
    makeWrapper ${luakit}/bin/luakit $out/bin/luakit --inherit-argv0 \
    ${lib.escapeShellArgs ([
      "--add-flag" "-c" "--add-flag" "${writeText "rc" "require('birdee')"}"
      "--prefix" "LUA_PATH" ";" (luajit.pkgs.luaLib.genLuaPathAbsStr final.passthru.luaEnv)
      "--prefix" "LUA_CPATH" ";" (luajit.pkgs.luaLib.genLuaCPathAbsStr final.passthru.luaEnv)
      "--prefix" "LUA_PATH" ";" "${placeholder "out"}/lua/?.lua;${placeholder "out"}/lua/?/init.lua"
      "--prefix" "LUA_CPATH" ";" "${placeholder "out"}/lua/?.so"
    ] ++ final.passthru.wrapperArgs)}
  '';
})
