{ pkgs, triggerFile, nameOfDir, xrandrPrimarySH, xrandrOthersSH, denyXDGoverride, ... }: let

    randrMemory = pkgs.writeScript "randrMemory.sh" (/*bash*/''
        #!/usr/bin/env ${pkgs.bash}/bin/bash
        bash() {
            ${pkgs.bash}/bin/bash "$@"
        }
        jq() {
            ${pkgs.jq}/bin/jq "$@"
        }
        xrandr() {
            ${pkgs.xorg.xrandr}/bin/xrandr "$@"
        }
        awk() {
            ${pkgs.gawk}/bin/awk "$@"
        }
        i3-msg() {
            ${pkgs.i3}/bin/i3-msg "$@"
        }
        i3msgpath=${pkgs.i3}/bin/i3-msg
        XRANDR_NEWMON_CONFIG=${xrandrOthersSH}
        XRANDR_ALWAYSRUN_CONFIG=${xrandrPrimarySH}
        #the script makes and uses this .json file. set it to an appropriate dir
        JSON_CACHE_PATH=/tmp/i3monsMemory/users/$USER/${nameOfDir}/userJsonCache.json
    ''+ (builtins.readFile ./i3autoXrandrMemory.sh));

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
