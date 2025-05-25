{
  stdenv,
  inputs,
  luajit,
  pandoc,
  makeBinaryWrapper,
  lib,
  ...
}: stdenv.mkDerivation {
  name = "antifennel";
  src = inputs.antifennel;
  nativeBuildInputs = [ makeBinaryWrapper luajit pandoc ];
  # dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp -r ./antifennel $out/bin
  '';
  postFixup = ''
    wrapProgram $out/bin/antifennel \
      --prefix PATH : ${lib.makeBinPath [luajit]}
  '';
}
