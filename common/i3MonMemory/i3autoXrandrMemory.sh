#Helper functions for getting and parsing info
check_conflict() {
    local arr1=("$1")  # First argument is array1
    local arr2=("$2")  # Second argument is array2
    for item1 in "${arr1[@]}"; do
        for item2 in "${arr2[@]}"; do
            if [[ "$item1" == "$item2" ]]; then
                return 0  # Element found, return success
            fi
        done
    done
    return 1  # No intersection, return failure
}
remove_by_mon() {
    local input="$1"
    local mon="$2"
    local result
    result="$(echo "$input" | jq --arg mon "$mon" -e 'map(select(.mon != $mon))')"
    if [ $? -eq 0 ]; then
        echo "$result"
        return 0  # Return success (0) since jq command succeeded
    else
        return 1  # Return non-zero value (indicating an error) since jq command failed
    fi
}
replace_json_nums() {
    local json="$1"
    local mon="$2"
    local -a new_nums=("${@:3}")
    # Convert the Bash array to a JSON array
    local new_nums_json=$(printf '%s,' "${new_nums[@]}")
    new_nums_json="[${new_nums_json%,}]"
    # Use jq to replace the "nums" array for the specified "mon"
    updated_json=$(jq --arg mon "$mon" --argjson new_nums "$new_nums_json" '
        map(if .mon == $mon then .nums = $new_nums else . end)
    ' <<< "$json")
    echo "$updated_json"
}
remove_elements() { # remove_elements in _______ from _________
    local -n array1="$1"  # Reference to the first array
    local -n array2="$2"  # Reference to the second array
    local result=()       # Resulting array without matching elements
    for item2 in "${array2[@]}"; do
        local found=false
        for item1 in "${array1[@]}"; do
            if [[ "$item2" == "$item1" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            result+=("$item2")
        fi
    done
    echo "${result[@]}"
}

#gather info before and after xrandr --auto
i3msgOUT="$(i3-msg -t get_workspaces)"
readarray -t initial_mons <<< "$(xrandr --listactivemonitors | awk '{print($4)}' | tail -n +2)"
xrandr --auto
readarray -t final_mons <<< "$(xrandr --listactivemonitors | awk '{print($4)}' | tail -n +2)"
gonemon=()
for initmon in "${initial_mons[@]}"; do
    found=false
    for finmon in "${final_mons[@]}"; do
        if [[ "$initmon" == "$finmon" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" == "false" ]]; then
        gonemon+=("$initmon")
    fi
done
newmon=()
for finmon in "${final_mons[@]}"; do
    found=false
    for initmon in "${initial_mons[@]}"; do
        if [[ "$finmon" == "$initmon" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" == "false" ]]; then
        newmon+=("$finmon")
    fi
done
#re-format info to appropriate json for turning into commands when needed
for mon in "${gonemon[@]}"; do
    filtered_data=$(echo "$i3msgOUT" | jq -M "map(select(.output==\"$mon\"))")
    nums=$(echo "$filtered_data" | jq -r '[.[].num]')
    result+='{ "mon": "'$mon'", "nums": '"$nums"' }'
done
result=$(echo "$result" | jq -s -c)
#Filter the cache, then append it and save it.
if [[ -e $JSON_CACHE_PATH && -s $JSON_CACHE_PATH ]]; then
    cacheresult="$(cat $JSON_CACHE_PATH)"
    if [[ -n "$cacheresult" ]]; then
        #old monitor cache for newly closed windows? Remove them from cache before we add new info for it later.
        for mon in "${gonemon[@]}"; do
            cacheresult="$(remove_by_mon "$cacheresult" "$mon")"
        done
    fi
    if [[ -n $cacheresult ]]; then
        readarray -t mons_array <<< "$(echo "$cacheresult" | jq -r '.[].mon')"
        if [[ -n "${mons_array[@]}" ]]; then
            for mon in "${mons_array[@]}"; do
                #also, if the workspace was moved to a different monitor, and then you unplug it, 
                #remove the workspace from the lists for other windows to avoid conflicts
                readarray -t cachenums_array <<< "$(echo "$cacheresult" | jq -r ".[] | select(.mon==\"$mon\") | .nums[]")"
                readarray -t nums_array <<< "$(echo "$result" | jq -r '.[].nums[]')"
                if [[ "${#nums_array[@]}" -gt 0 && "${nums_array[0]}" != "" && \
                    "${#cachenums_array[@]}" -gt 0 && "${cachenums_array[0]}" != "" && \
                    $(check_conflict "${cachenums_array[@]}" "${nums_array[@]}") -eq 0 ]]
                then
                    newcachenums_array=($(remove_elements nums_array cachenums_array))
                    cacheresult=$(replace_json_nums "$cacheresult" "$mon" "${newcachenums_array[@]}") 
                fi
            done
        fi
    fi
    #Combine result and cache appropriately
    cacheresult=${cacheresult%']'}
    cacheresult=${cacheresult#'['}
    result=${result%']'}
    result=${result#'['}
    [[ -n  "$result" && -n "$cacheresult" ]] && result+=","
    [[ -n "$cacheresult" ]] && result+=$cacheresult
    result="$(echo "[$result]" | jq -c)"
fi
#save the new cache
mkdir -p $(dirname $JSON_CACHE_PATH)
echo "$result" > $JSON_CACHE_PATH
#and now to move them back.
#using newmon and monwkspc.json, do extra monitor setups and then workspace moves for each newmon
workspace_commands=()
currentWkspc="$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).num')"
workspaceChecked="false"
for mon in "${newmon[@]}"; do
    [[ -e $XRANDR_NEWMON_CONFIG && -s $XRANDR_NEWMON_CONFIG ]] && \
        bash -c "$XRANDR_NEWMON_CONFIG \"$mon\""
    readarray -t nums_array <<< "$(echo "$result" | jq -r ".[] | select(.mon==\"$mon\") | .nums[]")"
    for num in "${nums_array[@]}"; do
        if [[ "$workspaceChecked" == "false" && "$currentWkspc" == "${nums_array[0]}" ]]; then
            #I do this check to ensure that it can still move the first one if you have it focused
            workspaceChecked="$(echo "$i3msgpath \"workspace number $num, move workspace to output $mon\";")"
        else
            workspace_commands+=("$(echo "$i3msgpath \"workspace number $num, move workspace to output $mon\";")")
        fi
        [[ "$workspaceChecked" == "false" ]] && workspaceChecked="true"
    done
done
[[ "$workspaceChecked" != "true" && "$workspaceChecked" != "false" ]] && \
    workspace_commands+=( "$workspaceChecked" )
for cmd in "${workspace_commands[@]}"; do
    bash -c "$cmd"
done
[[ -e $XRANDR_ALWAYSRUN_CONFIG && -s $XRANDR_ALWAYSRUN_CONFIG ]] && \
    exec $XRANDR_ALWAYSRUN_CONFIG ${final_mons[@]}

