{ pkgs, inputs, lib, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
  procPath = with pkgs; [
    coreutils
    findutils
    gnumake
    gnused
    gnugrep
    gawk
  ];
  luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
    luafilesystem
    cjson
    busted
    inspect
    http
  ]);
  appname = "REPLACE_ME";
in
stdenv.mkDerivation (let
  launcher = writeShellScript "${appname}" ''
    ${luaEnv}/bin/lua ${./src/${appname}.lua} "$@"
  '';
in {
  name = "${appname}";
  src = ./.;
  buildInputs = with pkgs; [  ];
  propagatedBuildInputs = with pkgs; [ luaEnv ] ++ procPath;
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
