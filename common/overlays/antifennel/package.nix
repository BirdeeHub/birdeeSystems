{
  stdenv,
  inputs,
  luajit,
  luapkgs ? luajit.pkgs,
  pandoc,
  fennel-ls,
  ...
}: stdenv.mkDerivation {
  name = "antifennel";
  src = inputs.antifennel;
  patches = [ ./interpreter.patch ];
  nativeBuildInputs = [ luapkgs.lua pandoc ];
  LUA = luapkgs.lua.interpreter;
  installPhase = ''
    make install PREFIX=$out
  '';
  checkInputs = [ luapkgs.luacheck fennel-ls ];
}
