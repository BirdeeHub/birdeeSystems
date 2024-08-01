{ pkgs, lib, writeShellScriptBin, home-manager, manix, gnused, coreutils, gnugrep, fzf, findutils, substituteAll, ... }: let
  inherit (pkgs) system;
  mnx = manix.overrideAttrs (fAttrs: pAttrs: {
    patches = [
      # (substituteAll {
      #   src = ./patchNOPSforFLAKE.diff;
      # })
    ];
  });
  nops = writeShellScriptBin "nops" (let
    procPath = [ home-manager.packages.${system}.home-manager mnx gnused coreutils gnugrep fzf findutils ];
  in /*bash*/''
    export PATH="${lib.makeBinPath procPath}:$PATH"
    manix -u
    manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
  '');
in
nops
