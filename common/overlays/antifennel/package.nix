{
  lib,
  stdenv,
  inputs,
  luajit,
  luapkgs ? luajit.pkgs,
  pandoc,
  fennel-ls,
  ...
}:
stdenv.mkDerivation rec {
  name = "antifennel";
  src = inputs.antifennel;
  patches = [ ./shebang.patch ];
  nativeBuildInputs = [ pandoc ];
  LUA = luapkgs.lua.interpreter;
  installPhase = ''
    make install PREFIX=$out
  '';
  checkInputs = [
    luapkgs.luacheck
    fennel-ls
  ];
  meta = {
    mainProgram = name;
    description = "fennel decompiler which produces fennel code from lua code";
    homepage = "https://git.sr.ht/~technomancy/antifennel";
    changelog = "https://git.sr.ht/~technomancy/antifennel/tree/${src.rev}/item/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ birdee ];
  };
}
