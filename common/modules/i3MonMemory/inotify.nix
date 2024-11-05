{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, ... }: let

    i3luaMon = {
      appname
      , userJsonCache ? null
      , xrandrOthersSH
      , xrandrPrimarySH
      , pkgs
      , lib
      , writeShellScript
      , stdenv
      , ...
    }: let
      procPath = with pkgs; [ i3 xorg.xrandr gawk ];
      luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
      luaProg = stdenv.mkDerivation {
        name = appname;
        src = ./${appname}.lua;
        phases = [ "buildPhase" ];
        buildPhase = ''
          ${luaEnv}/bin/luac -o $out $src
        '';
      };
      launcher = writeShellScript appname ''
        export PATH=${lib.makeBinPath procPath}
        ${luaEnv}/bin/lua ${luaProg} "${xrandrOthersSH}" "${xrandrPrimarySH}"''
            + (if userJsonCache == null then "" else '' "${userJsonCache}"'');
    in launcher;

    i3MonMemory = pkgs.callPackage i3luaMon {
        appname = "i3luaMon";
        inherit userJsonCache xrandrPrimarySH xrandrOthersSH;
    };

    i3notifyMon = pkgs.writeShellScript "runi3xrandrMemory.sh" ''
        export PATH="${pkgs.lib.makeBinPath (with pkgs; [ bash coreutils inotify-tools ])}:$PATH"
        mkdir -p "$(dirname ${triggerFile})"
        inotifywait -e close_write -m "$(dirname ${triggerFile})" |
        while read -r directory events filename; do
            if [ "$filename" == "$(basename ${triggerFile})" ]; then
                bash -c '${i3MonMemory}'
            fi
        done
    '';
in i3notifyMon
