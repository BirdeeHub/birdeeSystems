inputs: importName:
(
  final: prev: let
    manix = inputs.manix.packages.${prev.system}.manix.overrideAttrs {
      patches = [
        (prev.replaceVars ./patchManix4Flake.diff {
          homeManager = "${inputs.home-manager}";
        })
      ];
    };
    manixFZF = { lib, writeShellScriptBin, manix, gnused, gnugrep, fzf, findutils }:
      writeShellScriptBin importName ''
        export PATH="${lib.makeBinPath [ manix gnused gnugrep fzf findutils ]}:$PATH"
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
      '';
  in {
    ${importName} = final.callPackage manixFZF { };
    inherit manix;
  }
)
