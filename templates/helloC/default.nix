{ pkgs, inputs, lib, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
  procPath = with pkgs; [
    coreutils
    findutils
    gnumake
    gnused
    gnugrep
    gawk
  ];
  APPNAME = "HelloWorld";
in
stdenv.mkDerivation (let
in {
  name = "${APPNAME}";
  src = ./.;
  inherit APPNAME;
  # buildInputs = with pkgs; [  ];
  nativeBuildInputs = with pkgs; [ makeWrapper cmake ];
  # propagatedNativeBuildInputs = with pkgs; [  ];
  postFixup = ''
    wrapProgram $out/bin/${APPNAME} \
      --set PATH ${lib.makeBinPath procPath}
  '';
  meta = {
    mainProgram = "${APPNAME}";
  };
})
