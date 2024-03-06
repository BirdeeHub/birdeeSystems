{ pkgs, luaEnv, procPath, appname, inputs, lib, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
in
stdenv.mkDerivation (let
  launcher = writeShellScript "${appname}" ''
    ${luaEnv}/bin/lua ${./src/${appname}.lua} "$@"
  '';
in {
  name = "${appname}";
  src = ./.;
  buildInputs = with pkgs; [  ];
  propagatedBuildInputs = with pkgs; [ luaEnv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [  ];
  buildPhase = ''
    source $stdenv/setup
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp ${launcher} $out/bin/${appname}
    cp -r ./* $out/lib/
  '';
  installPhase = '''';
  postFixup = ''
    wrapProgram $out/bin/${appname} \
      --set PATH ${lib.makeBinPath procPath}
  '';
  passthru = { inherit luaEnv; };
  meta = {
    mainProgram = "${appname}";
  };
})
