{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, ... }: let

    i3luaMon = { pkgs
      , xrandrPrimarySH
      , xrandrOthersSH
      , lib
      , writeShellScript
      , stdenv
      , appname ? "i3luaMon"
      , userJsonCache ? null
      , ...
    }: let
      procPath = with pkgs; [ i3 xorg.xrandr gawk ];
      luaEnv = pkgs.lua5_2.withPackages (lpkgs: with lpkgs; [ luafilesystem cjson ]);
      luaProg = stdenv.mkDerivation {
        name = "${appname}";
        src = ./.;
        buildPhase = ''
          source $stdenv/setup
          ${luaEnv}/bin/luac -o $out ./${appname}.lua
        '';
        meta = {
          mainProgram = "${appname}";
        };
      };
      launcher = writeShellScript "${appname}" ''
        export PATH=${lib.makeBinPath procPath}
        ${luaEnv}/bin/lua ${luaProg} "${xrandrOthersSH}" "${xrandrPrimarySH}"''
            + (if userJsonCache == null then "" else '' "${userJsonCache}"'');
    in launcher;

    appname = "i3luaMon";
    randrMemory = pkgs.callPackage i3luaMon {
        inherit userJsonCache xrandrPrimarySH xrandrOthersSH appname;
    };

    i3notifyMon = (pkgs.writeShellScript "runi3xrandrMemory.sh" ''
        mkdir -p "$(dirname ${triggerFile})"
        ${pkgs.inotify-tools}/bin/inotifywait -e close_write -m "$(dirname ${triggerFile})" |
        while read -r directory events filename; do
            if [ "$filename" = "$(basename ${triggerFile})" ]; then
                ${pkgs.bash}/bin/bash -c '${randrMemory}'
            fi
        done
    '');
in i3notifyMon
