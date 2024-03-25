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
  # plz help I dont think Im doing any of this correctly
  name = "${appname}";
  src = ./.;
  phases = [ "buildPhase" "postFixup" ];
  buildInputs = with pkgs; [  ];
  nativeBuildInputs = with pkgs; [ makeWrapper cmake ];
  propagatedNativeBuildInputs = with pkgs; [  ];
  buildPhase = ''
    source $stdenv/setup
    mkdir -p $out
    export APPNAME=${appname}
    cd $out && cmake $src && make install
  '';
  postFixup = ''
    wrapProgram $out/bin/${appname} \
      --set PATH ${lib.makeBinPath procPath}
  '';
  meta = {
    mainProgram = "${appname}";
  };
})
