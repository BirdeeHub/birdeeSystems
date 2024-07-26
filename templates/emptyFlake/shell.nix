{ pkgs, APPNAME, inputs, lib, mkShell, symlinkJoin, writeTextDir, makeWrapper, stdenv, ... }: let
in
mkShell {
  packages = [ pkgs.${APPNAME} ];
  inputsFrom = [];
  DEVSHELL = 0;
  shellHook = ''
    exec ${pkgs.zsh}/bin/zsh
  '';
}
