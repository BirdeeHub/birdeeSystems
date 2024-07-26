{ pkgs, APPNAME, inputs, lib, symlinkJoin, writeTextDir, makeWrapper, stdenv, ... }: let
  APPPATH = with pkgs; [
    coreutils
    findutils
    gnumake
    gnused
    gnugrep
    gawk
  ];
  APPLINKABLES = with pkgs; [
  ];
  APPDRV = stdenv.mkDerivation {
    name = "${APPNAME}";
    src = ./src;
    buildInputs = [];
    nativeBuildInputs = [ makeWrapper ];
    buildPhase = ''
      source $stdenv/setup
      mkdir -p $out/bin
    '';
    installPhase = ''
    '';
    postFixup = ''
      wrapProgram $out/bin/${APPNAME} \
        --prefix PATH : ${lib.makeBinPath APPPATH} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath APPLINKABLES}
    '';
    # passthru = { };
  };
  DESKTOP = writeTextDir "share/applications/${APPNAME}.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=${APPNAME}
    Comment=Launches ${APPNAME}
    Terminal=false
    Exec=${APPDRV}/bin/${APPNAME}
  '';
in
symlinkJoin {
  name = APPNAME;
  paths = [ APPDRV DESKTOP ];
  meta = {
    mainProgram = APPNAME;
    # maintainers = [ lib.maintainers.birdee ];
  };
}
