{ pkgs, inputs, lib, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
  procPath = with pkgs; [
    coreutils
    findutils
    gnumake
    gnused
    gnugrep
    gawk
  ];
  appname = "HelloWorld";
in
stdenv.mkDerivation (let
in {
  name = "${appname}";
  src = ./.;
  APPNAME = appname;
  # buildInputs = with pkgs; [  ];
  nativeBuildInputs = with pkgs; [ makeWrapper cmake ];
  # propagatedNativeBuildInputs = with pkgs; [  ];
  postFixup = ''
    wrapProgram $out/bin/${appname} \
      --set PATH ${lib.makeBinPath procPath}
  '';
  meta = {
    mainProgram = "${appname}";
  };
})
