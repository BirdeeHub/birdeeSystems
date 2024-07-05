{ pkgs, inputs, lib, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
  procPath = with pkgs; [
    coreutils
    findutils
    gnumake
    gnused
    gnugrep
    gawk
  ];
  appname = "REPLACE_ME";
in
stdenv.mkDerivation (let
in {
  name = "${appname}";
  src = ./src;
  buildInputs = with pkgs; [  ];
  propagatedBuildInputs = with pkgs; [] ++ procPath;
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [] ++ procPath;
  buildPhase = ''
    source $stdenv/setup
    mkdir -p $out/bin
  '';
  installPhase = '''';
  postFixup = ''
    wrapProgram $out/bin/${appname} \
      --set PATH ${lib.makeBinPath procPath}
  '';
  # passthru = { };
  meta = {
    mainProgram = "${appname}";
  };
})
