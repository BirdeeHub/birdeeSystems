#!/usr/bin/env bash
channel="$1"
shift 1
infopath=${XDG_CACHE_HOME:-"$HOME/.cache"}/persistify/"$channel".inf
notificationID="$(<"$infopath")"
[[ "$notificationID" =~ ^[0-9]+$ ]] || {
    mkdir -p "$(dirname "$infopath")"
    notificationID=0
}
notify-send -p -r "$notificationID" "$@" > "$infopath"
