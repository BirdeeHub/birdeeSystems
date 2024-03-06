{ pkgs, lib, inputs, writeText, makeWrapper, writeShellScript, stdenv, ... }: let
  luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
    luafilesystem
    cjson
    busted
    inspect
    ]);
  nativePath = lib.makeBinPath (with pkgs; [
      coreutils
      findutils
      gnumake
      gnused
      gnugrep
      gawk
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
  # buildInputs = with pkgs; [  ];
  # propagatedBuildInputs = with pkgs; [  ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [ luaEnv ];
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
      --set PATH ${nativePath}
  '';
  passthru = { inherit luaEnv; };
  meta = {
    mainProgram = "${appname}";
  };
})
