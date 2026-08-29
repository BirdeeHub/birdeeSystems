#!/usr/bin/env bash
ipccmd=i3-msg
[[ -n "$1" ]] && ipccmd=swaymsg
#when you run it, it moves the current workspace to the next monitor in the list.
#Add a keybind to this script in ~/.i3/config so that you can do it with a keypress
currentWkspc="$("$ipccmd" -t get_workspaces | jq -r '.[] | select(.focused==true).num')"
currentMon="$("$ipccmd" -t get_outputs | jq -r ".[] | select(.current_workspace == \"$currentWkspc\") | .name")"
if [[ -n "$1" ]]; then
    readarray -t activeMons <<< "$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .name')"
else
    readarray -t activeMons <<< "$(xrandr --listactivemonitors | awk '{print($4)}' | tail -n +2)"
fi
#if we don't add 1st element to end, it will not "wrap" the list, and it will switch active focus if only 1 monitor rather than having no effect as expected
activeMons+=( "${activeMons[0]}" )
found="false"
for mon in "${activeMons[@]}"; do
    [[ "$found" == "true" && "$mon" != "$currentMon" ]] && exec "$ipccmd" "workspace number $currentWkspc, move workspace to output $mon"
    [[ "$mon" == "$currentMon" ]] && found="true" && "$ipccmd" "workspace number $currentWkspc"
    #selecting current workspace will swap focus to the previous workspace you focused temporarily, because you cannot move focused windows. If there was only 1 monitor, on the next iteration, the exec will not trigger, and we will switch it back.
done
