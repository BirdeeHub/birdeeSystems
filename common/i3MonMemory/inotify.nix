{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, ... }: let
    i3luaMon = { pkgs
      , xrandrPrimarySH
      , xrandrOthersSH
      , lib
      , makeWrapper
      , writeShellScript
      , stdenv
      , appname ? "i3luaMon"
      , userJsonCache ? null
      , ...
    }: stdenv.mkDerivation (let
      launcher = writeShellScript "${appname}" ''
        ${luaEnv}/bin/lua ${./${appname}.lua} "${xrandrOthersSH}" "${xrandrPrimarySH}"''
            + (if userJsonCache == null then "" else '' "${userJsonCache}"'');
      procPath = (with pkgs; [ i3 xorg.xrandr gawk ]);
      luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
    in {
      name = "${appname}";
      src = ./.;
      nativeBuildInputs = [ makeWrapper ];
      buildPhase = ''
        source $stdenv/setup
        mkdir -p $out/bin
        mkdir -p $out/lib
        cp ${launcher} $out/bin/${appname}
        cp ./${appname}.lua $out/lib/
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
    });

    appname = "i3luaMon";
    randrMemory = pkgs.callPackage i3luaMon {
        inherit userJsonCache xrandrPrimarySH xrandrOthersSH appname;
    };
    i3notifyMon = (pkgs.writeShellScript "runi3xrandrMemory.sh" ''
        mkdir -p "$(dirname ${triggerFile})"
        ${pkgs.inotify-tools}/bin/inotifywait -e close_write -m "$(dirname ${triggerFile})" |
        while read -r directory events filename; do
            if [ "$filename" = "$(basename ${triggerFile})" ]; then
                ${pkgs.bash}/bin/bash -c '${randrMemory}/bin/${appname}'
            fi
        done
    '');
in i3notifyMon
