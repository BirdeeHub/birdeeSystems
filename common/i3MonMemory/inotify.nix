{ pkgs, triggerFile, userJsonCache ? null, xrandrPrimarySH, xrandrOthersSH, ... }: let

    appname = "i3luaMon";
    randrMemory = pkgs.callPackage ./luaDRV.nix { inherit userJsonCache xrandrPrimarySH xrandrOthersSH appname; };

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
