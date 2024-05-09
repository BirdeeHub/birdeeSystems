  # TODO: TRY THIS OUT
  #NOTE: I HAVE NO CLUE IF THIS WORKS BUT IM DOING SOMETHING ELSE RIGHT NOW
  # JUST SAVING THIS FOR LATER TO TRY IT. GOT THIS FROM A REDDIT COMMENT BUT DIDNT BOOKMARK SO IDK WHERE...
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
    cqueues
    stdlib
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
