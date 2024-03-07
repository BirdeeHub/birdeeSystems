{ pkgs
, xrandrPrimarySH
, xrandrOthersSH
, lib
, makeWrapper
, writeShellScript
, stdenv
, appname ? "i3luaMon"
, userJsonCache ? null
, ...
}: let
  procPath = (with pkgs; [
    i3
    xorg.xrandr
    gawk
  ]);
  luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [
    luafilesystem
    cjson
  ]);
in
stdenv.mkDerivation (let
  launcher = writeShellScript "${appname}" ''
    ${luaEnv}/bin/lua ${./${appname}.lua} "${xrandrOthersSH}" "${xrandrPrimarySH}"'' + (if userJsonCache == null then "" else '' "${userJsonCache}"'');
in {
  name = "${appname}";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
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
