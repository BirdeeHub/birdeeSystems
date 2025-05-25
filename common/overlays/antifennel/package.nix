{
  stdenv,
  inputs,
  luajit,
  luapkgs ? luajit.pkgs,
  pandoc,
  ...
}: stdenv.mkDerivation {
  name = "antifennel";
  src = inputs.antifennel;
  nativeBuildInputs = [ luapkgs.lua pandoc ];
  LUA = luapkgs.lua.interpreter;
  installPhase = ''
    make install PREFIX=$out
  '';
}
