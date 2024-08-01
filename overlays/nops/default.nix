importName: inputs:
(
  final: prev: let
    manix = inputs.manix.packages.${prev.system}.manix.overrideAttrs {
      patches = [
        (prev.substituteAll {
          src = ./patchNOPSforFLAKE.diff;
          homeManager = "${inputs.home-manager}";
        })
      ];
    };
    nops = { lib, writeShellScriptBin, manix, gnused, coreutils, gnugrep, fzf, findutils }:
      writeShellScriptBin "nops" ''
        export PATH="${lib.makeBinPath [ manix gnused coreutils gnugrep fzf findutils ]}:$PATH"
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
      '';
  in {
    ${importName} = final.callPackage nops { };
    inherit manix;
  }
)
