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
    makeWrapper ${luakit}/bin/luakit $out/bin/luakit --inherit-argv0 \
    --prefix LUA_PATH ";" "$src/?.lua;$src/?/init.lua" \
    --prefix LUA_CPATH ";" "$src/?.so" \
    ${lib.escapeShellArgs ([
      "--add-flag" "-c" "--add-flag" "${writeText "rc" "require('birdee')"}"
      "--prefix" "LUA_PATH" ";" (luajit.pkgs.luaLib.genLuaPathAbsStr final.passthru.luaEnv)
      "--prefix" "LUA_CPATH" ";" (luajit.pkgs.luaLib.genLuaCPathAbsStr final.passthru.luaEnv)
    ] ++ final.passthru.wrapperArgs)}
  '';
})
