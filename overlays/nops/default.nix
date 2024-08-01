importName: inputs: (final: prev: let
  manix = inputs.manix.packages.${prev.system}.manix.overrideAttrs (fAttrs: pAttrs: {
    patches = [
      (prev.substituteAll {
        src = ./patchNOPSforFLAKE.diff;
        homeManager = "${inputs.home-manager}";
      })
    ];
  });
  nopsPKG = { lib, writeShellScriptBin, manix, gnused, coreutils, gnugrep, fzf, findutils, ... }:
  writeShellScriptBin "nops" (let
    procPath = [ manix gnused coreutils gnugrep fzf findutils ];
  in /*bash*/''
    export PATH="${lib.makeBinPath procPath}:$PATH"
    manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
  '');
in {
  ${importName} = prev.callPackage nopsPKG { inherit (inputs) home-manager; inherit manix; };
  inherit manix;
})
