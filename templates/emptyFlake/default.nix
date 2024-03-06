{ pkgs, lib, inputs, writeText, writeScript, makeWrapper, writeShellScript, stdenv, ... }: let
  luaEnv = ''${pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
    luafilesystem
    cjson
    busted
    inspect
    ])}/bin/lua'';
    appname = "REPLACE_ME";
in
stdenv.mkDerivation (let
  launcher = writeShellScript "${appname}" ''
    ${luaEnv} ${./${appname}.lua} "$@"
  '';
in {
  name = "${appname}";
  src = ./.;
  # buildInputs = with pkgs; [  ];
  # propagatedBuildInputs = with pkgs; [  ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  # propagatedNativeBuildInputs = with pkgs; [  ];
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
      --set PATH ${lib.makeBinPath (with pkgs; [
        coreutils
        findutils
        gnumake
        gnused
        gnugrep
        gawk
      ])}
  '';
  passthru = {};
  meta = {
    mainProgram = "${appname}";
  };
})
