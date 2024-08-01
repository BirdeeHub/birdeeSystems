{ lib, writeShellScriptBin, manix, gnused, coreutils, gnugrep, fzf, findutils }: let
  mnx = manix.overrideAttrs (fAttrs: pAttrs: {
  });
  nops = writeShellScriptBin "nops" (let
    procPath = [ mnx gnused coreutils gnugrep fzf findutils ];
  in /*bash*/''
    export PATH="${lib.makeBinPath procPath}:$PATH"
    manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
  '');
in
nops
